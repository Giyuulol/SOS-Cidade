enum ChamadoCategoria {
  transito,
  iluminacao,
  saneamento,
  seguranca,
  limpezaUrbana,
  desastreNatural,
}

enum ChamadoPrioridade { baixa, media, alta, critica }

enum ChamadoStatus { aberto, emAndamento, concluido }

extension ChamadoCategoriaLabel on ChamadoCategoria {
  String get label {
    return switch (this) {
      ChamadoCategoria.transito => 'Trânsito',
      ChamadoCategoria.iluminacao => 'Iluminação',
      ChamadoCategoria.saneamento => 'Saneamento',
      ChamadoCategoria.seguranca => 'Segurança',
      ChamadoCategoria.limpezaUrbana => 'Limpeza urbana',
      ChamadoCategoria.desastreNatural => 'Desastre natural',
    };
  }
}

extension ChamadoPrioridadeLabel on ChamadoPrioridade {
  String get label {
    return switch (this) {
      ChamadoPrioridade.baixa => 'Baixa',
      ChamadoPrioridade.media => 'Média',
      ChamadoPrioridade.alta => 'Alta',
      ChamadoPrioridade.critica => 'Crítica',
    };
  }
}

extension ChamadoStatusLabel on ChamadoStatus {
  String get label {
    return switch (this) {
      ChamadoStatus.aberto => 'Aberto',
      ChamadoStatus.emAndamento => 'Em andamento',
      ChamadoStatus.concluido => 'Concluído',
    };
  }
}
