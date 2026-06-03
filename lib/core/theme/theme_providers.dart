import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_controller.dart';

final themeControllerProvider = NotifierProvider<ThemeController, AppThemeMode>(
  ThemeController.new,
);

final materialThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeControllerProvider).materialThemeMode;
});
