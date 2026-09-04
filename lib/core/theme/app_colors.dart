import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const ink = Color(0xFF161A1F);
  static const inkSoft = Color(0xFF5B6167);
  static const inkFaint = Color(0xFF8B9096);
  static const paper = Color(0xFFFBFAF7);
  static const paper2 = Color(0xFFF1EFE7);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0x3D000000);
  static const lineSoft = Color(0x26000000);

  static const copper = Color(0xFF2F7BFF);
  static const copperLight = Color(0xFF63A0FF);
  static const copperDark = Color(0xFF1757C7);
  static const copperTint = Color(0xFFE7F0FF);

  static const blue = Color(0xFF2F7BFF);
  static const blueTint = Color(0xFFE7F0FF);
  static const blueDark = Color(0xFF1757C7);

  static const graphite = Color(0xFF33383F);
  static const graphiteTint = Color(0xFFEAEBEC);
  static const yellow = Color(0xFFE8A317);
  static const yellowTint = Color(0xFFFCF1DA);
  static const green = Color(0xFF2E8F5A);
  static const greenTint = Color(0xFFE5F3EA);
  static const red = Color(0xFFC1392B);
  static const redTint = Color(0xFFFBE8E5);

  // Premium black / graphite palette for dark mode.
  static const darkBackground = Color(0xFF07090C);
  static const darkSurface = Color(0xFF0B0F14);
  static const darkCard = Color(0xFF11161D);
  static const darkCardBlue = Color(0xFF111A28);
  static const darkLine = Color(0xFF1D2A3D);
  static const darkBlueSoft = Color(0xFF16253A);
  static const darkBlueGlow = Color(0xFF4D8DFF);

  /// Soft layered shadow for cards, tiles and panels.
  static List<BoxShadow> cardShadow({bool dark = false}) => dark
      ? [
          BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 22, offset: const Offset(0, 10), spreadRadius: -6),
          BoxShadow(color: Colors.black.withValues(alpha: .35), blurRadius: 6, offset: const Offset(0, 2), spreadRadius: -2),
        ]
      : [
          BoxShadow(color: const Color(0xFF1B2430).withValues(alpha: .10), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -8),
          BoxShadow(color: const Color(0xFF1B2430).withValues(alpha: .06), blurRadius: 6, offset: const Offset(0, 2), spreadRadius: -2),
        ];

  /// Lighter shadow for small chips, pills and compact controls.
  static List<BoxShadow> softShadow({bool dark = false}) => dark
      ? [BoxShadow(color: Colors.black.withValues(alpha: .4), blurRadius: 10, offset: const Offset(0, 4))]
      : [BoxShadow(color: const Color(0xFF1B2430).withValues(alpha: .09), blurRadius: 10, offset: const Offset(0, 4))];

  /// Pronounced shadow for floating/elevated controls (FAB-like add buttons, bottom bars).
  static List<BoxShadow> floatingShadow({bool dark = false, Color? tint}) => dark
      ? [
          BoxShadow(color: (tint ?? Colors.black).withValues(alpha: .45), blurRadius: 18, offset: const Offset(0, 8), spreadRadius: -4),
        ]
      : [
          BoxShadow(color: (tint ?? const Color(0xFF1B2430)).withValues(alpha: .22), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4),
        ];
}
