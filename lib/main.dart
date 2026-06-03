import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provedores/tema_provider.dart';
import 'telas/painel.dart';

void main() {
  runApp(const ProviderScope(child: AplicativoSosCidade()));
}

class AplicativoSosCidade extends ConsumerWidget {
  const AplicativoSosCidade({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(temaProvider).themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOS Cidade',
      theme: _criarTema(Brightness.light),
      darkTheme: _criarTema(Brightness.dark),
      themeMode: themeMode,
      home: const TelaPainel(),
    );
  }
}

ThemeData _criarTema(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0D6EFD),
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Rawline',
    brightness: brightness,
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
  );
}
