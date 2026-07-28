import 'package:flutter/material.dart';

// Palette de l'application (thème sombre facon "store de jeux")
const Color kBackground = Color(0xFF120F1A); // fond général
const Color kSurface = Color(0xFF1C1826); // cartes, barres, champs
const Color kAccent = Color(0xFF7C3AED); // violet principal
const Color kAccentLight = Color(0xFFA78BFA); // violet clair (textes accent)

// Thème global de l'application
ThemeData gameStoreTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kAccent,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: kBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: kSurface,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kSurface,
      selectedItemColor: kAccentLight,
      unselectedItemColor: Colors.white54,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
