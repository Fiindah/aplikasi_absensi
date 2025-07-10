// lib/constant/app_color.dart
import 'package:flutter/material.dart';

class AppColor {
  static const Color myblue2 = Color(0xFF1976D2); // Biru tua
  static const Color neutral = Color(0xFFF5F5F5); // Abu-abu muda
  static const Color primary = Color(0xFF2196F3); // Biru standar
  static const Color accent = Color(0xFFFFC107); // Kuning aksen
  static const Color myblue = Color(
    0xFF4E71FF,
  ); // Warna biru yang Anda inginkan (0xff4e71ff)
  static const Color gray88 = Color(0xFF757575); // Abu-abu gelap
  static const Color orange = Color(0xFFFFA726); // Oranye
}

// Helper function to create a MaterialColor from a single Color
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
