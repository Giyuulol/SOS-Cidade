import 'chamado_enums.dart';

final class Chamado {
  const Chamado({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.bairro,
    required this.responsavel,
    required this.data,
    required this.status,
  });

  final int? id;
  final String titulo;
  final String descricao;
  final ChamadoCategoria categoria;
  final ChamadoPrioridade prioridade;
  final String bairro;
  final String responsavel;
  final DateTime data;
  final ChamadoStatus status;

  bool get isCritico => prioridade == ChamadoPrioridade.critica;

  Duration tempoDesdeAbertura({DateTime? now}) {
    final reference = now ?? DateTime.now();
    if (data.isAfter(reference)) return Duration.zero;
    return reference.difference(data);
  }

  Chamado copyWith({
    int? id,
    String? titulo,
    String? descricao,
    ChamadoCategoria? categoria,
    ChamadoPrioridade? prioridade,
    String? bairro,
    String? responsavel,
    DateTime? data,
    ChamadoStatus? status,
  }) {
    return Chamado(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      prioridade: prioridade ?? this.prioridade,
      bairro: bairro ?? this.bairro,
      responsavel: responsavel ?? this.responsavel,
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }
}
