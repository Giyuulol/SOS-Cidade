import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'telas/painel.dart';
import 'provedores/chamado_provider.dart';

void main() {
  runApp(const AplicativoSosCidade());
}

class AplicativoSosCidade extends StatelessWidget {
  const AplicativoSosCidade({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChamadoProvider()..carregarChamados(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final seed = const Color(0xFF0D6EFD); // tom azul principal
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
              // CardTheme left to defaults to ensure compatibility across SDK versions
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            home: const TelaPainel(),
          );
        },
      ),
    );
  }
}
