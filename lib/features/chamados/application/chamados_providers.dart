import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_providers.dart';
import '../data/sqlite_chamado_repository.dart';
import '../domain/chamado.dart';
import '../domain/chamado_enums.dart';
import '../domain/chamado_repository.dart';
import 'chamados_controller.dart';

final chamadoRepositoryProvider = Provider<ChamadoRepository>((ref) {
  return SqliteChamadoRepository();
});

final chamadosControllerProvider =
    AsyncNotifierProvider<ChamadosController, List<Chamado>>(
      ChamadosController.new,
    );

final chamadosMetricsProvider = Provider((ref) {
  final chamados = ref.watch(chamadosControllerProvider).value ?? [];
  return ChamadosMetrics.from(chamados);
});

final notificationInitializationProvider = FutureProvider<void>((ref) {
  return ref.watch(notificationServiceProvider).initialize();
});

final class ChamadosMetrics {
  const ChamadosMetrics({
    required this.total,
    required this.abertos,
    required this.emAndamento,
    required this.concluidos,
    required this.criticos,
  });

  factory ChamadosMetrics.from(List<Chamado> chamados) {
    return ChamadosMetrics(
      total: chamados.length,
      abertos: chamados
          .where((chamado) => chamado.status == ChamadoStatus.aberto)
          .length,
      emAndamento: chamados
          .where((chamado) => chamado.status == ChamadoStatus.emAndamento)
          .length,
      concluidos: chamados
          .where((chamado) => chamado.status == ChamadoStatus.concluido)
          .length,
      criticos: chamados
          .where(
            (chamado) =>
                chamado.isCritico && chamado.status != ChamadoStatus.concluido,
          )
          .length,
    );
  }

  final int total;
  final int abertos;
  final int emAndamento;
  final int concluidos;
  final int criticos;

  bool get hasCriticalOverflow => criticos > 5;
}
