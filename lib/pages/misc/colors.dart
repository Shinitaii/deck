import 'package:flutter/material.dart';

class DeckColors {
  static const Color primaryColor = Color(0xFF28DF99);
  static const Color accentColor = Color(0xFF161616);
  static const Color gray = Color.fromARGB(255, 30, 30, 30);
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color green = Color(0xFF123524);
  static const Color white = Color(0xFFF3F3F3);
  static const Color coverImageColorSettings = Color(0xFF4C4C4C);
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.amber,
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF735761),
  onSecondary: Color(0xFFFFFFFF),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF000000),
  background: Color(0xFFF5F5F5),
  onBackground: Color(0xFF000000),
  error: Color(0xFFB00020),
  onError: Color(0xFFFFFFFF),
);
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.blue,
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF735761),
  onSecondary: Color(0xFFFFFFFF),
  surface: Color(0xFF121212),
  onSurface: Color(0xFFFFFFFF),
  background: Color(0xFF1E1E1E),
  onBackground: Color(0xFFFFFFFF),
  error: Color(0xFFB00020),
  onError: Color(0xFFFFFFFF),
);
