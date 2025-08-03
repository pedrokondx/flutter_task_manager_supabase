import 'package:flutter/material.dart';

class AppTheme {
  static final _lightBlue = Color(0xFF00AEEf); // Light blue from TeknaRocks

  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: _lightBlue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        backgroundColor: _lightBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightBlue, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
      bodySmall: TextStyle(fontSize: 14),
    ),
    useMaterial3: true,
  );
}
