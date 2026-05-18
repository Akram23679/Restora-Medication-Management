import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'services.dart';

class AppProvider extends ChangeNotifier {
  final _storage = StorageService.instance;
  final _uuid = const Uuid();

  // ── State ──────────────────────────────────────────────────────────────────
  UserProfile? _profile;
  List<Medication> _medications = [];
  List<DoseLog> _doseLogs = [];
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _isLoading = true;
  bool _isOnboarded = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  UserProfile? get profile => _profile;
  List<Medication> get medications => List.unmodifiable(_medications);
  List<DoseLog> get doseLogs => List.unmodifiable(_doseLogs);
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoading => _isLoading;
  bool get isOnboarded => _isOnboarded;

  // ── Computed: Today ────────────────────────────────────────────────────────
  List<DoseLog> get _todayLogs {
    final now = DateTime.now();
    return _doseLogs
        .where((l) =>
            l.takenAt.year == now.year &&
            l.takenAt.month == now.month &&
            l.takenAt.day == now.day)
        .toList();
  }

  int get dosesToday => _todayLogs.where((l) => l.taken).length;
  int get totalDosesToday => _medications.length;

  double get todayProgress =>
      totalDosesToday == 0 ? 0 : dosesToday / totalDosesToday;

  bool isTakenToday(String medId) =>
      _todayLogs.any((l) => l.medicationId == medId && l.taken);

  List<Medication> medsForPeriod(MedPeriod period) =>
      _medications.where((m) => m.period == period).toList();

  Medication? get nextMedication {
    try {
      return _medications.firstWhere((m) => !isTakenToday(m.id));
    } catch (_) {
      return null;
    }
  }

  // ── Computed: Greeting ─────────────────────────────────────────────────────
  String get greeting {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good morning';
    if (h >= 12 && h < 17) return 'Good afternoon';
    if (h >= 17 && h < 21) return 'Good evening';
    return 'Good night';
  }

  String get greetingSubtitle {
    if (_medications.isEmpty) {
      return 'Add your first medication to get started.';
    }
    final remaining = totalDosesToday - dosesToday;
    if (dosesToday == 0) return 'Start your day — take your first dose.';
    if (remaining == 0) return 'All doses taken. Excellent day!';
    return '$remaining dose${remaining > 1 ? "s" : ""} remaining. Keep going!';
  }

  // ── Computed: Adherence ────────────────────────────────────────────────────
  double get adherenceRate {
    if (_medications.isEmpty || _doseLogs.isEmpty) return 0;
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final recent = _doseLogs.where((l) => l.takenAt.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0;
    return recent.where((l) => l.taken).length / recent.length;
  }

  int get currentStreak {
    if (_medications.isEmpty) return 0;
    int streak = 0;
    DateTime day = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final dayLogs = _doseLogs.where((l) =>
          l.takenAt.year == day.year &&
          l.takenAt.month == day.month &&
          l.takenAt.day == day.day &&
          l.taken);
      if (dayLogs.isEmpty && i > 0) break;
      if (dayLogs.isNotEmpty) streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<double> get weeklyAdherence {
    if (_medications.isEmpty) return List.filled(7, 0);
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final logs = _doseLogs.where((l) =>
          l.takenAt.year == day.year &&
          l.takenAt.month == day.month &&
          l.takenAt.day == day.day);
      if (logs.isEmpty) return 0.0;
      return logs.where((l) => l.taken).length / logs.length;
    });
  }

  Map<MedPeriod, double> get adherenceByPeriod {
    final result = <MedPeriod, double>{};
    for (final period in MedPeriod.values) {
      final meds = medsForPeriod(period);
      if (meds.isEmpty) {
        result[period] = 0;
        continue;
      }
      final ids = meds.map((m) => m.id).toSet();
      final logs = _doseLogs.where((l) => ids.contains(l.medicationId)).toList();
      if (logs.isEmpty) {
        result[period] = 0;
        continue;
      }
      result[period] = logs.where((l) => l.taken).length / logs.length;
    }
    return result;
  }

  bool? dayStatus(DateTime day) {
    if (_medications.isEmpty) return null;
    final logs = _doseLogs.where((l) =>
        l.takenAt.year == day.year &&
        l.takenAt.month == day.month &&
        l.takenAt.day == day.day);
    if (logs.isEmpty) return null;
    return logs.every((l) => l.taken);
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await _storage.init();
    _darkMode = _storage.getBool('darkMode') ?? false;
    _notificationsEnabled = _storage.getBool('notifications') ?? true;
    _isOnboarded = _storage.getBool('onboarded') ?? false;

    final profileJson = _storage.getString('profile');
    if (profileJson != null) {
      _profile = UserProfile.fromJson(jsonDecode(profileJson));
    }

    final medsJson = _storage.getString('medications');
    if (medsJson != null) {
      final list = jsonDecode(medsJson) as List;
      _medications = list.map((j) => Medication.fromJson(j)).toList();
    }

    final logsJson = _storage.getString('doseLogs');
    if (logsJson != null) {
      final list = jsonDecode(logsJson) as List;
      _doseLogs = list.map((j) => DoseLog.fromJson(j)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding(
      UserProfile profile, List<Medication> meds) async {
    _profile = profile;
    _medications = List.from(meds);
    _isOnboarded = true;
    await _saveAll();
    notifyListeners();
  }

  Future<void> markDoseTaken(String medId) async {
    _removeLogToday(medId);
    _doseLogs.add(DoseLog(
      id: _uuid.v4(),
      medicationId: medId,
      takenAt: DateTime.now(),
      taken: true,
    ));
    await _saveLogs();
    notifyListeners();
  }

  Future<void> skipDose(String medId) async {
    _removeLogToday(medId);
    _doseLogs.add(DoseLog(
      id: _uuid.v4(),
      medicationId: medId,
      takenAt: DateTime.now(),
      taken: false,
    ));
    await _saveLogs();
    notifyListeners();
  }

  Future<void> undoDose(String medId) async {
    _removeLogToday(medId);
    await _saveLogs();
    notifyListeners();
  }

  Future<void> addMedication(Medication med) async {
    _medications.add(med);
    await _saveMeds();
    notifyListeners();
  }

  Future<void> updateMedication(Medication med) async {
    final idx = _medications.indexWhere((m) => m.id == med.id);
    if (idx != -1) {
      _medications[idx] = med;
      await _saveMeds();
      notifyListeners();
    }
  }

  Future<void> deleteMedication(String id) async {
    _medications.removeWhere((m) => m.id == id);
    _doseLogs.removeWhere((l) => l.medicationId == id);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile p) async {
    _profile = p;
    await _storage.setString('profile', jsonEncode(p.toJson()));
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    await _storage.setBool('darkMode', _darkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await _storage.setBool('notifications', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> resetAllData() async {
    _medications.clear();
    _doseLogs.clear();
    _profile = null;
    _isOnboarded = false;
    await _storage.clearAll();
    notifyListeners();
  }

  // ── Private ────────────────────────────────────────────────────────────────
  void _removeLogToday(String medId) {
    final now = DateTime.now();
    _doseLogs.removeWhere((l) =>
        l.medicationId == medId &&
        l.takenAt.year == now.year &&
        l.takenAt.month == now.month &&
        l.takenAt.day == now.day);
  }

  Future<void> _saveAll() async {
    await _saveMeds();
    await _saveLogs();
    if (_profile != null) {
      await _storage.setString('profile', jsonEncode(_profile!.toJson()));
    }
    await _storage.setBool('onboarded', _isOnboarded);
  }

  Future<void> _saveMeds() async {
    await _storage.setString(
      'medications',
      jsonEncode(_medications.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> _saveLogs() async {
    // Keep only last 90 days
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    _doseLogs.removeWhere((l) => l.takenAt.isBefore(cutoff));
    await _storage.setString(
      'doseLogs',
      jsonEncode(_doseLogs.map((l) => l.toJson()).toList()),
    );
  }
}