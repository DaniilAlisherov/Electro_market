import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(TextTheme base, {required bool dark}) {
    final foreground = dark ? const Color(0xFFF4F8FF) : AppColors.ink;
    final muted = dark ? const Color(0xFF9CAEC4) : AppColors.inkFaint;
    return base.copyWith(
      headlineSmall: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 21, letterSpacing: -.45, color: foreground),
      titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -.3, color: foreground),
      titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15, color: foreground),
      bodyLarge: GoogleFonts.inter(fontSize: 15, color: foreground),
      bodyMedium: GoogleFonts.inter(fontSize: 13, color: foreground),
      bodySmall: GoogleFonts.inter(fontSize: 11.5, color: muted),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5, color: foreground),
    );
  }

  static ThemeData _base({required bool dark}) {
    final base = ThemeData(useMaterial3: true, brightness: dark ? Brightness.dark : Brightness.light);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: dark ? AppColors.darkBlueGlow : AppColors.copper,
      onPrimary: Colors.white,
      secondary: dark ? const Color(0xFF8BB6FF) : AppColors.blue,
      surface: dark ? AppColors.darkBackground : AppColors.paper,
      surfaceContainerLowest: dark ? const Color(0xFF05070A) : Colors.white,
      surfaceContainer: dark ? AppColors.darkCard : Colors.white,
      surfaceContainerHigh: dark ? const Color(0xFF151C25) : AppColors.paper2,
      surfaceContainerHighest: dark ? AppColors.darkCardBlue : AppColors.paper2,
      outline: dark ? AppColors.darkLine : AppColors.line,
      outlineVariant: dark ? const Color(0xFF162232) : AppColors.lineSoft,
      onSurface: dark ? const Color(0xFFF4F7FB) : AppColors.ink,
      onSurfaceVariant: dark ? const Color(0xFF9AA8BB) : AppColors.inkSoft,
      error: AppColors.red,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      colorScheme: scheme,
      textTheme: _textTheme(base.textTheme, dark: dark),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18, color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: scheme.outlineVariant)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF0D131B) : AppColors.paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: scheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: scheme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: AppColors.red)),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
      dividerColor: scheme.outlineVariant,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFF111A26) : AppColors.ink,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? scheme.primary : null),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? scheme.primary.withValues(alpha: .38) : null),
      ),
      splashFactory: NoSplash.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get light => _base(dark: false);
  static ThemeData get dark => _base(dark: true);
}
