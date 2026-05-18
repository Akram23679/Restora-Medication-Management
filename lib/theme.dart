import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color card;
  final Color surface;
  final Color primary;
  final Color primaryMuted;
  final Color textDark;
  final Color textMid;
  final Color textLight;
  final Color progressBg;
  final Color divider;
  final Color errorColor;

  const AppColors({
    required this.bg,
    required this.card,
    required this.surface,
    required this.primary,
    required this.primaryMuted,
    required this.textDark,
    required this.textMid,
    required this.textLight,
    required this.progressBg,
    required this.divider,
    required this.errorColor,
  });

  static const light = AppColors(
    bg: Color(0xFFF5F0E8),
    card: Color(0xFFFFFFFF),
    surface: Color(0xFFF0EBE0),
    primary: Color(0xFF1B4A3C),
    primaryMuted: Color(0xFF8FB8AD),
    textDark: Color(0xFF1A1A1A),
    textMid: Color(0xFF5C5C5C),
    textLight: Color(0xFF9A9A9A),
    progressBg: Color(0xFFE8E3D8),
    divider: Color(0xFFEEEAE0),
    errorColor: Color(0xFFD9534F),
  );

  static const dark = AppColors(
    bg: Color(0xFF0F1512),
    card: Color(0xFF1C2420),
    surface: Color(0xFF243029),
    primary: Color(0xFF5BA690),
    primaryMuted: Color(0xFF3D7A6A),
    textDark: Color(0xFFF0EDE6),
    textMid: Color(0xFFADABA5),
    textLight: Color(0xFF5E6360),
    progressBg: Color(0xFF243029),
    divider: Color(0xFF2A3530),
    errorColor: Color(0xFFE57373),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? card,
    Color? surface,
    Color? primary,
    Color? primaryMuted,
    Color? textDark,
    Color? textMid,
    Color? textLight,
    Color? progressBg,
    Color? divider,
    Color? errorColor,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      primaryMuted: primaryMuted ?? this.primaryMuted,
      textDark: textDark ?? this.textDark,
      textMid: textMid ?? this.textMid,
      textLight: textLight ?? this.textLight,
      progressBg: progressBg ?? this.progressBg,
      divider: divider ?? this.divider,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryMuted: Color.lerp(primaryMuted, other.primaryMuted, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
      textMid: Color.lerp(textMid, other.textMid, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      progressBg: Color.lerp(progressBg, other.progressBg, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
    );
  }
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bg,
      fontFamily: 'Georgia',
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: colors.primaryMuted,
        onSecondary: isDark ? Colors.black : Colors.white,
        error: colors.errorColor,
        onError: Colors.white,
        surface: colors.card,
        onSurface: colors.textDark,
      ),
      extensions: [colors],
      dividerColor: colors.divider,
      dialogTheme: DialogThemeData(backgroundColor: colors.card),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}