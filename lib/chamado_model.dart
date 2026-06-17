class Atualizacao {
  final String responsavel;
  final String descricao;
  final String statusAlterado;
  final DateTime data;

  Atualizacao({
    required this.responsavel,
    required this.descricao,
    required this.statusAlterado,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'responsavel': responsavel,
      'descricao': descricao,
      'statusAlterado': statusAlterado,
      'data': data.toIso8601String(),
    };
  }

  factory Atualizacao.fromMap(Map<String, dynamic> map) {
    return Atualizacao(
      responsavel: map['responsavel'],
      descricao: map['descricao'],
      statusAlterado: map['statusAlterado'],
      data: DateTime.parse(map['data']),
    );
  }
}

class Chamado {
  final String id;
  final String titulo;
  final String descricao;
  final String category; // Mapeado internamente
  final String categoria;
  final String prioridade;
  final String bairro;
  final String responsavelOriginal;
  final DateTime dataAbertura;
  final String status;
  final DateTime dataUltimaAtualizacao;
  final List<Atualizacao> historico;

  Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.bairro,
    required this.responsavelOriginal,
    required this.dataAbertura,
    required this.status,
    required this.dataUltimaAtualizacao,
    required this.historico,
  }) : category = categoria;

  String get tempoDesdeAbertura {
    final diferenca = DateTime.now().difference(dataAbertura);
    if (diferenca.inMinutes < 60) return 'Há ${diferenca.inMinutes} min';
    if (diferenca.inHours < 24) return 'Há ${diferenca.inHours} h';
    return 'Há ${diferenca.inDays} dias';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'prioridade': prioridade,
      'bairro': bairro,
      'responsavelOriginal': responsavelOriginal,
      'dataAbertura': dataAbertura.toIso8601String(),
      'status': status,
      'dataUltimaAtualizacao': dataUltimaAtualizacao.toIso8601String(),
      'historico': historico.map((h) => h.toMap()).toList(),
    };
  }

  factory Chamado.fromMap(Map<String, dynamic> map) {
    return Chamado(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      categoria: map['categoria'] ?? map['category'] ?? 'trânsito',
      prioridade: map['prioridade'],
      bairro: map['bairro'],
      responsavelOriginal:
          map['responsavelOriginal'] ?? map['responsavel'] ?? 'Anônimo',
      dataAbertura: DateTime.parse(map['dataAbertura']),
      status: map['status'],
      dataUltimaAtualizacao:
          DateTime.parse(map['dataUltimaAtualizacao'] ?? map['dataAbertura']),
      historico: (map['historico'] as List<dynamic>?)
              ?.map((h) => Atualizacao.fromMap(h))
              .toList() ??
          [],
    );
  }
}
