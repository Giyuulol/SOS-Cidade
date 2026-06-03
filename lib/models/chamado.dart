class Chamado {
  const Chamado({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.bairro,
    required this.responsavel,
    required this.dataAbertura,
    required this.status,
    this.favorito = false,
  });

  final int? id;
  final String titulo;
  final String descricao;
  final String categoria;
  final String prioridade;
  final String bairro;
  final String responsavel;
  final DateTime dataAbertura;
  final String status;
  final bool favorito;

  Chamado copyWith({
    int? id,
    String? titulo,
    String? descricao,
    String? categoria,
    String? prioridade,
    String? bairro,
    String? responsavel,
    DateTime? dataAbertura,
    String? status,
    bool? favorito,
  }) {
    return Chamado(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      prioridade: prioridade ?? this.prioridade,
      bairro: bairro ?? this.bairro,
      responsavel: responsavel ?? this.responsavel,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      status: status ?? this.status,
      favorito: favorito ?? this.favorito,
    );
  }

  factory Chamado.fromMap(Map<String, Object?> map) {
    return Chamado(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      categoria: map['categoria'] as String,
      prioridade: map['prioridade'] as String,
      bairro: map['bairro'] as String,
      responsavel: map['responsavel'] as String,
      // support both storage keys: 'dataAbertura' (sqlite) and 'data_abertura' (legacy)
      dataAbertura: DateTime.parse(
        (map['dataAbertura'] ?? map['data_abertura']) as String,
      ),
      status: map['status'] as String,
      favorito: (map['favorito'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'prioridade': prioridade,
      'bairro': bairro,
      'responsavel': responsavel,
      'dataAbertura': dataAbertura.toIso8601String(),
      'status': status,
      'favorito': favorito ? 1 : 0,
    };
  }
}
