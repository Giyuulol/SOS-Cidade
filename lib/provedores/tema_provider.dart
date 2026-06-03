import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../database/db_helper.dart';

final temaProvider = ChangeNotifierProvider<TemaProvider>((ref) {
  final provider = TemaProvider();
  provider.carregarTema();
  return provider;
});

class TemaProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> carregarTema() async {
    try {
      final valor = await DbHelper.instance.getSetting('themeMode');
      if (valor == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (valor == 'light') {
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (_) {
      // Ignora erro se banco de dados ainda não estiver inicializado/criado
    }
  }

  Future<void> alternarTema() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    try {
      await DbHelper.instance.saveSetting(
        'themeMode',
        isDarkMode ? 'dark' : 'light',
      );
    } catch (_) {}
  }
}
