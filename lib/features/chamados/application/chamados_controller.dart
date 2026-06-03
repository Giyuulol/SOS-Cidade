import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_providers.dart';
import '../domain/chamado.dart';
import '../domain/chamado_enums.dart';
import 'chamado_business_exception.dart';
import 'chamados_providers.dart';

/// Application layer dos chamados.
///
/// SRP: coordena casos de uso de chamados; não renderiza UI e não conhece SQL.
final class ChamadosController extends AsyncNotifier<List<Chamado>> {
  @override
  Future<List<Chamado>> build() async {
    final repository = ref.watch(chamadoRepositoryProvider);
    await repository.ensureSeedData();
    return _sortByBusinessPriority(await repository.findAll());
  }

  Future<void> createChamado(Chamado chamado) async {
    final repository = ref.read(chamadoRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final chamadosAtuais = await repository.findAll();

    _validateCreate(chamado: chamado, chamadosAtuais: chamadosAtuais);

    final created = await repository.create(chamado);
    final chamados = _sortByBusinessPriority(await repository.findAll());
    state = AsyncData(chamados);

    await notificationService.showNewChamadoNotification(
      chamadoTitle: created.titulo,
      prioridade: created.prioridade.label,
    );

    final criticalCount = chamados.where((item) => item.isCritico).length;
    if (created.isCritico) {
      await notificationService.showCriticalAlert(
        title: 'Chamado crítico criado',
        body: '${created.titulo} em ${created.bairro}',
      );
    }

    if (criticalCount > 5) {
      await notificationService.showCriticalAlert(
        title: 'Alerta de chamados críticos',
        body: 'Existem $criticalCount chamados críticos ativos.',
      );
    }
  }

  Future<void> updateStatus({
    required Chamado chamado,
    required ChamadoStatus status,
  }) async {
    if (chamado.id == null) {
      throw StateError('Chamado sem identificador não pode ser atualizado.');
    }

    if (chamado.status == ChamadoStatus.concluido) {
      throw StateError('Chamados concluídos não podem ter status alterado.');
    }

    final repository = ref.read(chamadoRepositoryProvider);
    await repository.updateStatus(chamadoId: chamado.id!, status: status);
    state = AsyncData(_sortByBusinessPriority(await repository.findAll()));
  }

  void _validateCreate({
    required Chamado chamado,
    required List<Chamado> chamadosAtuais,
  }) {
    if (chamado.titulo.trim().isEmpty) {
      throw const ChamadoBusinessException('Título é obrigatório.');
    }

    final normalizedTitle = chamado.titulo.trim().toLowerCase();
    final hasDuplicateTitle = chamadosAtuais.any(
      (item) => item.titulo.trim().toLowerCase() == normalizedTitle,
    );

    if (hasDuplicateTitle) {
      throw const ChamadoBusinessException(
        'Já existe um chamado com esse título.',
      );
    }

    if (chamado.descricao.trim().isEmpty) {
      throw const ChamadoBusinessException('Descrição é obrigatória.');
    }

    if (chamado.bairro.trim().isEmpty) {
      throw const ChamadoBusinessException('Bairro é obrigatório.');
    }
  }

  List<Chamado> _sortByBusinessPriority(List<Chamado> chamados) {
    final sorted = [...chamados];
    sorted.sort((a, b) {
      final priorityComparison = _priorityWeight(
        b.prioridade,
      ).compareTo(_priorityWeight(a.prioridade));

      if (priorityComparison != 0) return priorityComparison;
      return b.data.compareTo(a.data);
    });

    return sorted;
  }

  int _priorityWeight(ChamadoPrioridade prioridade) {
    return switch (prioridade) {
      ChamadoPrioridade.critica => 4,
      ChamadoPrioridade.alta => 3,
      ChamadoPrioridade.media => 2,
      ChamadoPrioridade.baixa => 1,
    };
  }
}
