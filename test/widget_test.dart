import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sos_cidade/provedores/chamado_provider.dart';
import 'package:sos_cidade/telas/painel.dart';

void main() {
  testWidgets('mostra o painel principal', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [chamadoProvider.overrideWith((ref) => ChamadoProvider())],
        child: const MaterialApp(home: TelaPainel()),
      ),
    );

    expect(find.text('Novo chamado'), findsOneWidget);
  });
}
