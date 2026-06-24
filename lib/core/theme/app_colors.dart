import 'package:flutter/material.dart';

/// Premium, dark-first color palette for Vynema.
class AppColors {
  const AppColors._();

  // Brand accent — a vivid cinematic violet/magenta.
  static const Color primary = Color(0xFF7C4DFF);
  static const Color secondary = Color(0xFFFF4D8D);
  static const Color accent = Color(0xFF00E0C6);

  // Dark surfaces.
  static const Color darkBackground = Color(0xFF0B0B12);
  static const Color darkSurface = Color(0xFF15151F);
  static const Color darkSurfaceVariant = Color(0xFF1E1E2C);

  // Light surfaces.
  static const Color lightBackground = Color(0xFFF6F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color star = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5252);

  /// Background gradient used behind primary screens (dark).
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B0B12), Color(0xFF15101F), Color(0xFF0B0B12)],
  );

  /// Brand gradient for accents, buttons and rating badges.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  /// Scrim drawn over poster images so foreground text stays legible.
  static const LinearGradient posterScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
    stops: [0.45, 1.0],
  );
}
