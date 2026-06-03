import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

extension AppThemeModeMapper on AppThemeMode {
  ThemeMode get materialThemeMode {
    return switch (this) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }
}

/// Controller de tema.
///
/// Strategy Pattern: cada valor de `AppThemeMode` representa uma estrategia
/// visual diferente que o `MaterialApp` aplica globalmente.
final class ThemeController extends Notifier<AppThemeMode> {
  static const _storageKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    _loadPersistedMode();
    return AppThemeMode.system;
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }

  Future<void> toggleLightDark() async {
    final nextMode = state == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setMode(nextMode);
  }

  Future<void> _loadPersistedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_storageKey);
    if (value == null) return;

    state = AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}
