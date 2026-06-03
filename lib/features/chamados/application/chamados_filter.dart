import '../domain/chamado.dart';

/// Filter Object: encapsula criterios de busca fora da UI.
///
/// Open/Closed Principle: novos filtros podem entrar neste objeto e no metodo
/// `matches` sem reescrever o Dashboard.
final class ChamadosFilter {
  const ChamadosFilter({this.searchTerm = ''});

  final String searchTerm;

  ChamadosFilter copyWith({String? searchTerm}) {
    return ChamadosFilter(searchTerm: searchTerm ?? this.searchTerm);
  }

  bool matches(Chamado chamado) {
    final normalizedTerm = searchTerm.trim().toLowerCase();
    if (normalizedTerm.isEmpty) return true;

    return chamado.titulo.toLowerCase().contains(normalizedTerm) ||
        chamado.descricao.toLowerCase().contains(normalizedTerm) ||
        chamado.bairro.toLowerCase().contains(normalizedTerm);
  }
}
