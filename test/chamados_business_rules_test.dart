import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_cidade/core/notifications/app_notification_service.dart';
import 'package:sos_cidade/core/notifications/notification_providers.dart';
import 'package:sos_cidade/features/chamados/application/chamado_business_exception.dart';
import 'package:sos_cidade/features/chamados/application/chamados_providers.dart';
import 'package:sos_cidade/features/chamados/domain/chamado.dart';
import 'package:sos_cidade/features/chamados/domain/chamado_enums.dart';
import 'package:sos_cidade/features/chamados/domain/chamado_repository.dart';

void main() {
  test('prioridade alta ou crítica aparece no topo', () async {
    final container = _createContainer(_BusinessRulesRepository());
    addTearDown(container.dispose);

    final chamados = await container.read(chamadosControllerProvider.future);

    expect(chamados.first.prioridade, ChamadoPrioridade.critica);
    expect(chamados[1].prioridade, ChamadoPrioridade.alta);
  });

  test('não permite título repetido', () async {
    final container = _createContainer(_BusinessRulesRepository());
    addTearDown(container.dispose);

    await container.read(chamadosControllerProvider.future);

    await expectLater(
      container
          .read(chamadosControllerProvider.notifier)
          .createChamado(
            Chamado(
              titulo: 'Semáforo apagado',
              descricao: 'Mesmo título já existente',
              categoria: ChamadoCategoria.transito,
              prioridade: ChamadoPrioridade.media,
              bairro: 'Centro',
              responsavel: 'Trânsito',
              data: DateTime(2026, 5, 27),
              status: ChamadoStatus.aberto,
            ),
          ),
      throwsA(isA<ChamadoBusinessException>()),
    );
  });

  test('calcula tempo desde a abertura', () {
    final chamado = Chamado(
      titulo: 'Teste',
      descricao: 'Descrição válida',
      categoria: ChamadoCategoria.saneamento,
      prioridade: ChamadoPrioridade.baixa,
      bairro: 'Centro',
      responsavel: 'Equipe',
      data: DateTime(2026, 5, 27, 8),
      status: ChamadoStatus.aberto,
    );

    final duration = chamado.tempoDesdeAbertura(
      now: DateTime(2026, 5, 27, 10, 30),
    );

    expect(duration.inMinutes, 150);
  });

  test('chamado crítico concluído conta como concluído, não como crítico', () {
    final metrics = ChamadosMetrics.from([
      Chamado(
        titulo: 'Alagamento resolvido',
        descricao: 'Equipe finalizou atendimento',
        categoria: ChamadoCategoria.desastreNatural,
        prioridade: ChamadoPrioridade.critica,
        bairro: 'Centro',
        responsavel: 'Defesa Civil',
        data: DateTime(2026, 5, 27, 8),
        status: ChamadoStatus.concluido,
      ),
    ]);

    expect(metrics.criticos, 0);
    expect(metrics.concluidos, 1);
  });
}

ProviderContainer _createContainer(ChamadoRepository repository) {
  return ProviderContainer(
    overrides: [
      chamadoRepositoryProvider.overrideWithValue(repository),
      notificationServiceProvider.overrideWithValue(_NoopNotificationService()),
    ],
  );
}

final class _BusinessRulesRepository implements ChamadoRepository {
  final List<Chamado> _chamados = [
    Chamado(
      id: 1,
      titulo: 'Coleta atrasada',
      descricao: 'Lixo acumulado há dois dias',
      categoria: ChamadoCategoria.limpezaUrbana,
      prioridade: ChamadoPrioridade.baixa,
      bairro: 'Centro',
      responsavel: 'Limpeza Urbana',
      data: DateTime(2026, 5, 27, 8),
      status: ChamadoStatus.aberto,
    ),
    Chamado(
      id: 2,
      titulo: 'Semáforo apagado',
      descricao: 'Cruzamento sem sinalização',
      categoria: ChamadoCategoria.transito,
      prioridade: ChamadoPrioridade.critica,
      bairro: 'Tambaú',
      responsavel: 'Trânsito',
      data: DateTime(2026, 5, 27, 9),
      status: ChamadoStatus.aberto,
    ),
    Chamado(
      id: 3,
      titulo: 'Poste sem luz',
      descricao: 'Rua escura durante a noite',
      categoria: ChamadoCategoria.iluminacao,
      prioridade: ChamadoPrioridade.alta,
      bairro: 'Bessa',
      responsavel: 'Iluminação',
      data: DateTime(2026, 5, 27, 10),
      status: ChamadoStatus.aberto,
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
  }) async {}
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
