import 'package:flutter/material.dart';

class AppDesign {
  static const Color monsterRed = Color(0xFFC62828);
  static const Color darkSlate = Color(0xFF263238);
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: monsterRed,
      primary: monsterRed,
      secondary: darkSlate,
    ),
    scaffoldBackgroundColor: backgroundGrey,
    appBarTheme: const AppBarTheme(
      backgroundColor: monsterRed,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}