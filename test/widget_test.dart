import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_cidade/core/notifications/app_notification_service.dart';
import 'package:sos_cidade/core/notifications/notification_providers.dart';
import 'package:sos_cidade/features/chamados/application/chamados_providers.dart';
import 'package:sos_cidade/features/chamados/domain/chamado.dart';
import 'package:sos_cidade/features/chamados/domain/chamado_enums.dart';
import 'package:sos_cidade/features/chamados/domain/chamado_repository.dart';
import 'package:sos_cidade/main.dart';

void main() {
  testWidgets('Dashboard lists and searches chamados', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamadoRepositoryProvider.overrideWithValue(_FakeChamadoRepository()),
          notificationServiceProvider.overrideWithValue(
            _NoopNotificationService(),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Painel de chamados'), findsOneWidget);
    expect(find.text('Semáforo sem funcionar'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'centro');
    await tester.pumpAndSettle();

    expect(find.text('Vazamento na Avenida Central'), findsOneWidget);
    expect(find.text('Semáforo sem funcionar'), findsNothing);
  });
}

final class _FakeChamadoRepository implements ChamadoRepository {
  final List<Chamado> _chamados = [
    Chamado(
      id: 1,
      titulo: 'Vazamento na Avenida Central',
      descricao: 'Água escorrendo na via',
      categoria: ChamadoCategoria.saneamento,
      prioridade: ChamadoPrioridade.alta,
      bairro: 'Centro',
      responsavel: 'Equipe Hidráulica',
      data: DateTime(2026, 5, 27, 10),
      status: ChamadoStatus.aberto,
    ),
    Chamado(
      id: 2,
      titulo: 'Semáforo sem funcionar',
      descricao: 'Cruzamento perigoso',
      categoria: ChamadoCategoria.transito,
      prioridade: ChamadoPrioridade.critica,
      bairro: 'São José',
      responsavel: 'Trânsito',
      data: DateTime(2026, 5, 27, 9),
      status: ChamadoStatus.emAndamento,
    ),
  ];

  @override
  Future<Chamado> create(Chamado chamado) async {
    final created = chamado.copyWith(id: _chamados.length + 1);
    _chamados.add(created);
    return created;
  }

  @override
  Future<void> ensureSeedData() async {}

  @override
  Future<List<Chamado>> findAll() async {
    return List.unmodifiable(_chamados);
  }

  @override
  Future<void> updateStatus({
    required int chamadoId,
    required ChamadoStatus status,
  }) async {
    final index = _chamados.indexWhere((chamado) => chamado.id == chamadoId);
    if (index == -1) return;
    _chamados[index] = _chamados[index].copyWith(status: status);
  }
}

final class _NoopNotificationService implements AppNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showCriticalAlert({
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> showNewChamadoNotification({
    required String chamadoTitle,
    required String prioridade,
  }) async {}
}
