enum MedPeriod { morning, afternoon, evening, night }

extension MedPeriodExt on MedPeriod {
  String get label {
    switch (this) {
      case MedPeriod.morning:
        return 'Morning';
      case MedPeriod.afternoon:
        return 'Afternoon';
      case MedPeriod.evening:
        return 'Evening';
      case MedPeriod.night:
        return 'Night';
    }
  }

  String get defaultTime {
    switch (this) {
      case MedPeriod.morning:
        return '08:00';
      case MedPeriod.afternoon:
        return '13:00';
      case MedPeriod.evening:
        return '19:00';
      case MedPeriod.night:
        return '22:00';
    }
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String purpose;
  final String detail;
  final String time;
  final MedPeriod period;
  final String iconName;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.purpose,
    required this.detail,
    required this.time,
    required this.period,
    required this.iconName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'purpose': purpose,
        'detail': detail,
        'time': time,
        'period': period.index,
        'iconName': iconName,
      };

  factory Medication.fromJson(Map<String, dynamic> j) => Medication(
        id: j['id'],
        name: j['name'],
        dosage: j['dosage'],
        purpose: j['purpose'],
        detail: j['detail'],
        time: j['time'],
        period: MedPeriod.values[j['period']],
        iconName: j['iconName'],
      );

  Medication copyWith({
    String? name,
    String? dosage,
    String? purpose,
    String? detail,
    String? time,
    MedPeriod? period,
    String? iconName,
  }) =>
      Medication(
        id: id,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        purpose: purpose ?? this.purpose,
        detail: detail ?? this.detail,
        time: time ?? this.time,
        period: period ?? this.period,
        iconName: iconName ?? this.iconName,
      );
}

class DoseLog {
  final String id;
  final String medicationId;
  final DateTime takenAt;
  final bool taken;

  const DoseLog({
    required this.id,
    required this.medicationId,
    required this.takenAt,
    required this.taken,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicationId': medicationId,
        'takenAt': takenAt.toIso8601String(),
        'taken': taken,
      };

  factory DoseLog.fromJson(Map<String, dynamic> j) => DoseLog(
        id: j['id'],
        medicationId: j['medicationId'],
        takenAt: DateTime.parse(j['takenAt']),
        taken: j['taken'],
      );
}

class UserProfile {
  final String name;
  final String email;
  final String bloodType;
  final List<String> allergies;

  const UserProfile({
    required this.name,
    required this.email,
    required this.bloodType,
    required this.allergies,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'bloodType': bloodType,
        'allergies': allergies,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: j['name'],
        email: j['email'],
        bloodType: j['bloodType'],
        allergies: List<String>.from(j['allergies']),
      );

  UserProfile copyWith({
    String? name,
    String? email,
    String? bloodType,
    List<String>? allergies,
  }) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        bloodType: bloodType ?? this.bloodType,
        allergies: allergies ?? this.allergies,
      );
}