import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'theme.dart';

// ── App Bar ───────────────────────────────────────────────────────────────────
class RestoraAppBar extends StatelessWidget {
  final String subtitle;
  final bool showSettings;
  final VoidCallback? onAction;

  const RestoraAppBar({
    super.key,
    required this.subtitle,
    this.showSettings = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: c.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.opacity,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Restora',
                      style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          color: c.textDark)),
                ],
              ),
              GestureDetector(
                onTap: onAction,
                child: Icon(
                  showSettings
                      ? Icons.settings_outlined
                      : Icons.notifications_outlined,
                  color: c.textDark,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: c.divider, height: 1),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: c.textLight)),
        ],
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────
class RestoraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;

  const RestoraCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ?? c.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ── Primary Button ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  final bool enabled;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: (loading || !enabled) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: enabled ? c.primary : c.progressBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ))
              : Text(label,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: enabled ? Colors.white : c.textLight,
                  )),
        ),
      ),
    );
  }
}

// ── Shimmer Loading ───────────────────────────────────────────────────────────
class ShimmerCard extends StatelessWidget {
  final double height;

  const ShimmerCard({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A3530) : const Color(0xFFE8E3D8),
      highlightColor:
          isDark ? const Color(0xFF3D4E48) : const Color(0xFFF5F0E8),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A3530) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: c.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 22,
                    color: c.textDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    color: c.textMid,
                    height: 1.5),
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(actionLabel!,
                      style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                fontSize: 22,
                color: c.textDark)),
        if (trailing != null)
          Text(trailing!,
              style: TextStyle(
                  fontFamily: 'Arial', fontSize: 12, color: c.textMid)),
      ],
    );
  }
}

// ── Med Icon Mapper ───────────────────────────────────────────────────────────
IconData medIcon(String name) {
  switch (name) {
    case 'heart':
      return Icons.favorite_outline;
    case 'spa':
      return Icons.spa_outlined;
    case 'moon':
      return Icons.nights_stay_outlined;
    case 'water':
      return Icons.water_drop_outlined;
    case 'leaf':
      return Icons.eco_outlined;
    case 'brain':
      return Icons.psychology_outlined;
    case 'eye':
      return Icons.visibility_outlined;
    case 'bone':
      return Icons.accessibility_outlined;
    default:
      return Icons.medication_outlined;
  }
}

// ── Text Field ────────────────────────────────────────────────────────────────
class RestoraTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final VoidCallback? onChanged;

  const RestoraTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboard,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      onChanged: (_) => onChanged?.call(),
      style: TextStyle(fontFamily: 'Arial', color: c.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontFamily: 'Arial', color: c.textLight, fontSize: 13),
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
  }
}