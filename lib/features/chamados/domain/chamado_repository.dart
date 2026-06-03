import 'chamado.dart';
import 'chamado_enums.dart';

/// Contrato de persistencia dos chamados.
///
/// Repository Pattern: a application layer nao conhece SQLite, tabelas ou SQL.
abstract interface class ChamadoRepository {
  Future<List<Chamado>> findAll();

  Future<Chamado> create(Chamado chamado);

  Future<void> updateStatus({
    required int chamadoId,
    required ChamadoStatus status,
  });

  Future<void> ensureSeedData();
}
