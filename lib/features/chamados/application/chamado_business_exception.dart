/// Erro de regra de negócio da feature de chamados.
///
/// Evita usar exceções genéricas para fluxo esperado de validação e permite
/// que a UI mostre mensagens amigaveis sem conhecer a regra internamente.
final class ChamadoBusinessException implements Exception {
  const ChamadoBusinessException(this.message);

  final String message;

  @override
  String toString() => message;
}
