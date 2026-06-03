import 'package:flutter/material.dart';

/// Contrato visual central do app.
///
/// Design Pattern aplicado: Design Tokens. Centralizar cores, formas e estados
/// reduz acoplamento entre telas e identidade visual, facilitando manutenção.
abstract final class AppTheme {
  static const _primary = Color(0xFF0891B2);
  static const _secondary = Color(0xFF22D3EE);
  static const _accent = Color(0xFF059669);
  static const _background = Color(0xFFECFEFF);
  static const _foreground = Color(0xFF164E63);
  static const _muted = Color(0xFFE8F1F6);
  static const _border = Color(0xFFA5F3FC);
  static const _destructive = Color(0xFFDC2626);
  static const _darkBackground = Color(0xFF0B1720);
  static const _darkSurface = Color(0xFF102534);
  static const _darkForeground = Color(0xFFE6F6FA);

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: _primary,
          onPrimary: Colors.white,
          secondary: _secondary,
          tertiary: _accent,
          surface: Colors.white,
          error: _destructive,
          outline: _border,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _foreground, fontSize: 16, height: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _destructive),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: _muted),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _secondary,
          onPrimary: _darkBackground,
          secondary: _primary,
          tertiary: _accent,
          surface: _darkSurface,
          error: Colors.redAccent,
          outline: const Color(0xFF2B5263),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkForeground,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: _darkForeground,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2B5263)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2B5263)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        surfaceTintColor: _darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF17384A)),
        ),
      ),
    );
  }
}
