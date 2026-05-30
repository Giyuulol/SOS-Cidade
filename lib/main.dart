import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'telas/painel.dart';

void main() {
  runApp(const ProviderScope(child: AplicativoSosCidade()));
}

class AplicativoSosCidade extends StatelessWidget {
  const AplicativoSosCidade({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF0D6EFD);
    final scheme = ColorScheme.fromSeed(seedColor: seed);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOS Cidade',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          centerTitle: false,
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
      ),
      home: const TelaPainel(),
    );
  }
}
