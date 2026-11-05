import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Accent {
  const Accent(this.name, this.light, this.dark);
  final String name;
  final Color light; // used in light mode
  final Color dark; // brighter variant used in dark mode
}

const accents = <Accent>[
  Accent('Royal blue', Color(0xFF0B2E86), Color(0xFF4F8CF0)),
  Accent('Teal', Color(0xFF0B6E6E), Color(0xFF3CC8B8)),
  Accent('Violet', Color(0xFF5B2EA6), Color(0xFFA98BFF)),
  Accent('Coral', Color(0xFFC2410C), Color(0xFFFF8A5B)),
];

extension SchemeX on ColorScheme {
  bool get isDark => brightness == Brightness.dark;

  /// Deep tone of the accent, used for the home header and hero areas.
  Color get hero => Color.lerp(primary, Colors.black, isDark ? 0.62 : 0.28)!;

  /// Slightly raised fill for chat bubbles, inputs and tiles.
  Color get soft => surfaceContainerHighest;
}

/// Handwritten "marker" style used for the brand moments.
TextStyle markerStyle(double size, Color color, {double height = 1.0}) =>
    GoogleFonts.permanentMarker(fontSize: size, color: color, height: height);

ThemeData buildTheme(Brightness b, Accent accent) {
  final dark = b == Brightness.dark;
  final primary = dark ? accent.dark : accent.light;
  final onPrimary = primary.computeLuminance() > 0.4
      ? const Color(0xFF0A1226)
      : Colors.white;

  final bg = dark ? const Color(0xFF0A1226) : const Color(0xFFF3ECE2);
  final surface = dark ? const Color(0xFF131D38) : const Color(0xFFFBF8F3);
  final soft = dark ? const Color(0xFF1B2747) : const Color(0xFFEFE6DA);
  final text = dark ? const Color(0xFFEAF0FF) : const Color(0xFF14213D);
  final muted = dark ? const Color(0xFF93A0BF) : const Color(0xFF6B7280);
  final outline = dark ? const Color(0xFF26324F) : const Color(0xFFE3D9CB);

  final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: b)
      .copyWith(
    primary: primary,
    onPrimary: onPrimary,
    surface: surface,
    onSurface: text,
    onSurfaceVariant: muted,
    outline: outline,
    outlineVariant: outline,
    surfaceContainerHighest: soft,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme)
      .apply(bodyColor: text, displayColor: text);

  return base.copyWith(
    scaffoldBackgroundColor: bg,
    textTheme: textTheme,
    dividerColor: outline,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: surface,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primary.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? primary : muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? primary : muted);
      }),
    ),
  );
}
