import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models.dart';
import '../provider.dart';
import '../widgets.dart';
import 'onboarding.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.profile;
    final c = context.colors;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RestoraAppBar(
                subtitle: 'PROFILE — SETTINGS & HEALTH INFO',
                showSettings: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                  color: c.primary,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 44),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () =>
                                    _editProfile(context, provider),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: c.card,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 6)
                                    ],
                                  ),
                                  child: Icon(Icons.edit,
                                      size: 14, color: c.textDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          profile?.name.isEmpty ?? true
                              ? 'Your Name'
                              : profile!.name,
                          style: TextStyle(
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic,
                              fontSize: 28,
                              color: c.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile?.email.isEmpty ?? true
                              ? 'Tap edit to add email'
                              : profile!.email,
                          style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 13,
                              color: c.textLight),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Health Profile
                  Text('Health Profile',
                      style: TextStyle(
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontSize: 20,
                          color: c.textDark)),
                  const SizedBox(height: 14),

                  if ((profile?.bloodType.isEmpty ?? true) &&
                      (profile?.allergies.isEmpty ?? true))
                    RestoraCard(
                      onTap: () => _editProfile(context, provider),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline,
                              color: c.primary, size: 20),
                          const SizedBox(width: 12),
                          Text('Add health information',
                              style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  color: c.primary)),
                        ],
                      ),
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile?.bloodType.isNotEmpty ?? false)
                          Expanded(
                            child: RestoraCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(Icons.water_drop_outlined,
                                        color: c.textLight, size: 13),
                                    const SizedBox(width: 6),
                                    Text('BLOOD TYPE',
                                        style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 9,
                                            letterSpacing: 1.2,
                                            color: c.textLight)),
                                  ]),
                                  const SizedBox(height: 10),
                                  Text(profile?.bloodType ?? '',
                                      style: TextStyle(
                                          fontFamily: 'Georgia',
                                          fontStyle: FontStyle.italic,
                                          fontSize: 22,
                                          color: c.textDark)),
                                ],
                              ),
                            ),
                          ),
                        if ((profile?.bloodType.isNotEmpty ?? false) &&
                            (profile?.allergies.isNotEmpty ?? false))
                          const SizedBox(width: 12),
                        if (profile?.allergies.isNotEmpty ?? false)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: c.primary,
                                  borderRadius:
                                      BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(Icons.warning_amber_outlined,
                                        color: c.primaryMuted,
                                        size: 13),
                                    const SizedBox(width: 6),
                                    Text('ALLERGIES',
                                        style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 9,
                                            letterSpacing: 1.2,
                                            color: c.primaryMuted)),
                                  ]),
                                  const SizedBox(height: 10),
                                  Text(
                                    profile!.allergies.join(',\n'),
                                    style: const TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 28),

                  // ── Account Settings
                  Text('Account Settings',
                      style: TextStyle(
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontSize: 20,
                          color: c.textDark)),
                  const SizedBox(height: 14),

                  RestoraCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingsRow(
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          subtitle: 'Switch to dark appearance',
                          trailing: Switch(
                            value: provider.darkMode,
                            onChanged: (_) =>
                                provider.toggleDarkMode(),
                            activeTrackColor: c.primary,
                            activeThumbColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: c.progressBg,
                          ),
                          showDivider: true,
                        ),
                        _SettingsRow(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Medication dose reminders',
                          trailing: Switch(
                            value: provider.notificationsEnabled,
                            onChanged: (_) =>
                                provider.toggleNotifications(),
                            activeTrackColor: c.primary,
                            activeThumbColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: c.progressBg,
                          ),
                          showDivider: true,
                        ),
                        _SettingsRow(
                          icon: Icons.lock_outline,
                          title: 'Privacy & Security',
                          subtitle: 'Data sharing and biometric lock',
                          trailing: Icon(Icons.chevron_right,
                              color: c.textLight),
                          showDivider: true,
                        ),
                        _SettingsRow(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Premium Membership',
                          subtitle: 'Renews Oct 12, 2026',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: c.primary.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(20)),
                            child: Text('ACTIVE',
                                style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w700,
                                    color: c.primary)),
                          ),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Danger zone
                  RestoraCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => _confirmReset(context, provider),
                    child: Row(
                      children: [
                        Icon(Icons.restart_alt,
                            color: c.errorColor, size: 20),
                        const SizedBox(width: 14),
                        Text('Reset All Data',
                            style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: c.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(profile: provider.profile),
    ).then((updated) {
      if (updated is UserProfile && context.mounted) {
        provider.updateProfile(updated);
      }
    });
  }

  void _confirmReset(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.card,
        title: Text('Reset All Data?',
            style: TextStyle(
                fontFamily: 'Georgia',
                color: context.colors.textDark)),
        content: Text(
            'This deletes all medications, logs, and settings. Cannot be undone.',
            style: TextStyle(
                fontFamily: 'Arial', color: context.colors.textMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: context.colors.textMid)),
          ),
          TextButton(
            onPressed: () async {
              await provider.resetAllData();
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const OnboardingScreen()),
                (_) => false,
              );
            },
            child: Text('Reset',
                style: TextStyle(color: context.colors.errorColor)),
          ),
        ],
      ),
    );
  }
}

// ── Settings Row ──────────────────────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool showDivider;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: c.primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.textDark)),
                    Text(subtitle,
                        style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            color: c.textLight)),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
        if (showDivider)
          Divider(
              color: c.divider, height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

// ── Edit Profile Sheet ────────────────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final UserProfile? profile;
  const _EditProfileSheet({this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bloodCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      final p = widget.profile!;
      _nameCtrl.text = p.name;
      _emailCtrl.text = p.email;
      _bloodCtrl.text = p.bloodType;
      _allergyCtrl.text = p.allergies.join(', ');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bloodCtrl.dispose();
    _allergyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final updated = UserProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      bloodType: _bloodCtrl.text.trim(),
      allergies: _allergyCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: BoxDecoration(
          color: c.card,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Edit Profile',
                style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 26,
                    color: c.textDark)),
            const SizedBox(height: 24),
            RestoraTextField(label: 'Full name', controller: _nameCtrl),
            const SizedBox(height: 14),
            RestoraTextField(
                label: 'Email',
                controller: _emailCtrl,
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 14),
            RestoraTextField(
                label: 'Blood type (e.g. A+)',
                controller: _bloodCtrl),
            const SizedBox(height: 14),
            RestoraTextField(
                label: 'Allergies (comma-separated)',
                controller: _allergyCtrl),
            const SizedBox(height: 28),
            PrimaryButton(label: 'Save Profile', onTap: _save),
          ],
        ),
      ),
    );
  }
}