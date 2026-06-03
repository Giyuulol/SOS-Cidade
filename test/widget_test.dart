import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sos_cidade/main.dart';
import 'package:sos_cidade/models/chamado.dart';
import 'package:sos_cidade/provedores/chamado_provider.dart';
import 'package:sos_cidade/telas/cadastro.dart';
import 'package:sos_cidade/telas/painel.dart';

void main() {
  testWidgets('mostra o painel principal', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamadoProvider.overrideWith((ref) => ChamadoProvider(ref)),
        ],
        child: const MaterialApp(home: TelaPainel()),
      ),
    );

    expect(find.text('Novo chamado'), findsOneWidget);
  });

  testWidgets('alterna para modo escuro pelo botao do painel', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamadoProvider.overrideWith((ref) => ChamadoProvider(ref)),
        ],
        child: const AplicativoSosCidade(),
      ),
    );

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    final toggle = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.dark_mode_outlined),
    );
    toggle.onPressed!();
    await tester.pump();

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('acao de status usa botao visivel no modo escuro', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamadoProvider.overrideWith((ref) => _ChamadoProviderComItem(ref)),
        ],
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D6EFD),
              brightness: Brightness.dark,
            ),
          ),
          home: const TelaPainel(),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(OutlinedButton, 'Mudar status');
    expect(buttonFinder, findsOneWidget);

    final button = tester.widget<OutlinedButton>(buttonFinder);
    final colorScheme = Theme.of(tester.element(buttonFinder)).colorScheme;

    expect(
      button.style?.foregroundColor?.resolve(<WidgetState>{}),
      colorScheme.primary,
    );
    expect(tester.getSize(buttonFinder).height, greaterThanOrEqualTo(48));
  });

  testWidgets('painel reserva espaco inferior para o botao novo chamado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamadoProvider.overrideWith((ref) => ChamadoProvider(ref)),
        ],
        child: const MaterialApp(home: TelaPainel()),
      ),
    );

    final listView = tester.widget<ListView>(find.byType(ListView));

    expect(listView.padding, const EdgeInsets.fromLTRB(16, 16, 16, 104));
  });

  testWidgets('titulo remove simbolos e preserva letras numeros e espacos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamadoProvider.overrideWith((ref) => ChamadoProvider(ref)),
        ],
        child: const MaterialApp(home: TelaCadastro()),
      ),
    );

    final tituloFinder = _campoComLabel('Título');

    await tester.enterText(tituloFinder, '!#Árvore caída Rua 10%^');
    await tester.pump();

    expect(
      tester.widget<TextFormField>(tituloFinder).controller?.text,
      'Árvore caída Rua 10',
    );
  });

  testWidgets('descricao mostra caracteres restantes e limita a 1000', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamadoProvider.overrideWith((ref) => ChamadoProvider(ref)),
        ],
        child: const MaterialApp(home: TelaCadastro()),
      ),
    );

    final descricaoFinder = _campoComLabel('Descrição');

    expect(find.text('1000 caracteres restantes'), findsOneWidget);

    await tester.enterText(descricaoFinder, 'Vazamento constante');
    await tester.pump();

    expect(find.text('981 caracteres restantes'), findsOneWidget);

    await tester.enterText(descricaoFinder, List.filled(1001, 'a').join());
    await tester.pump();

    expect(
      tester.widget<TextFormField>(descricaoFinder).controller?.text.length,
      1000,
    );
  });

  testWidgets('busca por texto limpa com o botao X', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamadoProvider.overrideWith((ref) => ChamadoProvider(ref)),
        ],
        child: const MaterialApp(home: TelaPainel()),
      ),
    );

    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'Vazamento');
    await tester.pumpAndSettle();

    final clearButton = find.widgetWithIcon(IconButton, Icons.clear);
    expect(clearButton, findsOneWidget);

    final clearButtonWidget = tester.widget<IconButton>(clearButton);
    clearButtonWidget.onPressed!();
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(searchField).controller?.text, '');
  });
}

Finder _campoComLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(TextFormField),
  );
}

class _ChamadoProviderComItem extends ChamadoProvider {
  _ChamadoProviderComItem(super.ref);

  final List<Chamado> _itens = [
    Chamado(
      id: 1,
      titulo: 'Semáforo quebrado',
      descricao: 'Semáforo não está funcionando.',
      categoria: 'Trânsito',
      prioridade: 'Alta',
      bairro: 'Centro',
      responsavel: 'Ana Silva',
      dataAbertura: DateTime(2026, 6, 2, 10),
      status: 'Em Andamento',
    ),
  ];

  @override
  List<Chamado> get chamados => _itens;

  @override
  int get total => _itens.length;

  @override
  int get abertos => 0;

  @override
  int get emAndamento => 1;

  @override
  int get concluidos => 0;

  @override
  int get criticos => 0;

  @override
  int get favoritosTotal => _itens.where((c) => c.favorito).length;
}
