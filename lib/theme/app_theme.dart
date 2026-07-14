import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTurquoise = Color(0xFF2EFEEA); 
  static const Color backgroundBlack = Color(0xFF121212);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static final ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: backgroundBlack,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundBlack,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryTurquoise),
      titleTextStyle: TextStyle(
        color: primaryTurquoise, 
        fontSize: 22, 
        fontWeight: FontWeight.bold,
        fontFamily: 'Arial',
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: pureWhite, fontFamily: 'Arial'),
      bodyMedium: TextStyle(color: pureWhite, fontFamily: 'Arial'),
    ),
  );
}