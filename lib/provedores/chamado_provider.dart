import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/chamado.dart';
import '../database/db_helper.dart';
import 'notificacao_provider.dart';

final chamadoProvider = ChangeNotifierProvider<ChamadoProvider>((ref) {
  final provider = ChamadoProvider(ref);
  provider.carregarChamados();
  return provider;
});

class ChamadoProvider extends ChangeNotifier {
  ChamadoProvider(this.ref);
  final Ref ref;

  List<Chamado> _chamadosBase = [];
  List<Chamado> _chamadosProcessados = [];

  String _buscaQuery = '';
  String _filtroBairro = '';
  bool _apenasFavoritos = false;
  int _ultimoCriticos = 0;

  List<Chamado> get chamados => _chamadosProcessados;

  String get buscaQuery => _buscaQuery;
  set buscaQuery(String val) {
    _buscaQuery = val;
    _atualizarListaProcessada();
  }

  String get filtroBairro => _filtroBairro;
  set filtroBairro(String val) {
    _filtroBairro = val;
    _atualizarListaProcessada();
  }

  bool get apenasFavoritos => _apenasFavoritos;
  set apenasFavoritos(bool val) {
    _apenasFavoritos = val;
    _atualizarListaProcessada();
  }

  int get total => _chamadosProcessados.length;
  int get abertos =>
      _chamadosProcessados.where((c) => c.status == 'Aberto').length;
  int get emAndamento =>
      _chamadosProcessados.where((c) => c.status == 'Em Andamento').length;
  int get concluidos =>
      _chamadosProcessados.where((c) => c.status == 'Concluído').length;
  int get criticos => _chamadosProcessados
      .where((c) => c.prioridade == 'Crítica' && c.status != 'Concluído')
      .length;

  bool get exibirAlertaCritico => criticos > 5;
  int get favoritosTotal => _chamadosBase.where((c) => c.favorito).length;

  List<String> get bairrosDisponiveis {
    final todosBairros = _chamadosBase
        .map((c) => c.bairro.trim())
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();
    todosBairros.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return todosBairros;
  }

  List<Map<String, dynamic>> get rankingBairros {
    final contagem = <String, int>{};
    for (final c in _chamadosBase) {
      final b = c.bairro.trim();
      if (b.isNotEmpty) {
        contagem[b] = (contagem[b] ?? 0) + 1;
      }
    }
    final lista = contagem.entries
        .map((e) => {'bairro': e.key, 'total': e.value})
        .toList();
    lista.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
    return lista;
  }

  void _atualizarListaProcessada() {
    var listaFiltrada = List<Chamado>.from(_chamadosBase);

    // Filtrar por busca (titulo e descricao)
    if (_buscaQuery.isNotEmpty) {
      final query = _buscaQuery.toLowerCase().trim();
      listaFiltrada = listaFiltrada
          .where(
            (c) =>
                c.titulo.toLowerCase().contains(query) ||
                c.descricao.toLowerCase().contains(query),
          )
          .toList();
    }

    // Filtrar por bairro
    if (_filtroBairro.isNotEmpty) {
      listaFiltrada = listaFiltrada
          .where((c) => c.bairro.trim().toLowerCase() == _filtroBairro.toLowerCase())
          .toList();
    }

    // Filtrar apenas favoritos
    if (_apenasFavoritos) {
      listaFiltrada = listaFiltrada.where((c) => c.favorito).toList();
    }

    // Ordenação
    listaFiltrada.sort((a, b) {
      int peso(String prioridade) {
        switch (prioridade.toLowerCase()) {
          case 'crítica':
            return 4;
          case 'alta':
            return 3;
          case 'média':
            return 2;
          default:
            return 1;
        }
      }

      final comparacaoPrioridade = peso(
        b.prioridade,
      ).compareTo(peso(a.prioridade));

      if (comparacaoPrioridade != 0) {
        return comparacaoPrioridade;
      }

      return b.dataAbertura.compareTo(a.dataAbertura);
    });

    _chamadosProcessados = listaFiltrada;
    notifyListeners();

    // Notificar automaticamente se número de chamados críticos ultrapassar 5
    final novosCriticos = _chamadosBase
        .where((c) => c.prioridade == 'Crítica' && c.status != 'Concluído')
        .length;
    if (novosCriticos > 5 && _ultimoCriticos <= 5) {
      ref.read(notificacaoProvider).adicionarNotificacao(
        'Alerta Crítico: Existem $novosCriticos chamados com prioridade Crítica ativos no momento!',
      );
    }
    _ultimoCriticos = novosCriticos;
  }

  Future<void> carregarChamados() async {
    try {
      final rows = await DbHelper.instance.fetchChamados();
      _chamadosBase = rows
          .map((m) => Chamado.fromMap(Map<String, Object?>.from(m)))
          .toList();
      _atualizarListaProcessada();
    } catch (_) {
      // Ignora erro se o banco não estiver inicializado (como em testes)
    }
  }

  bool existeTituloRepetido(String titulo, {int? idIgnorar}) {
    return _chamadosBase.any(
      (c) =>
          c.titulo.trim().toLowerCase() == titulo.trim().toLowerCase() &&
          c.id != idIgnorar,
    );
  }

  Future<bool> adicionarChamado(Chamado chamado) async {
    if (existeTituloRepetido(chamado.titulo)) return false;

    final map = chamado.toMap();
    map.remove('id');

    final id = await DbHelper.instance.insertChamado(
      Map<String, dynamic>.from(map),
    );

    if (id > 0) {
      final novo = chamado.copyWith(id: id);
      _chamadosBase = [..._chamadosBase, novo];
      _atualizarListaProcessada();

      ref.read(notificacaoProvider).adicionarNotificacao(
        'Novo chamado registrado: "${novo.titulo}" no bairro ${novo.bairro}.',
      );
      return true;
    }
    return false;
  }

  Future<void> atualizarChamado(Chamado chamado) async {
    final idx = _chamadosBase.indexWhere((c) => c.id == chamado.id);
    if (idx != -1) {
      final antigo = _chamadosBase[idx];
      await DbHelper.instance.updateChamado(
        chamado.toMap().map((k, v) => MapEntry(k, v)),
      );
      final novosChamados = [..._chamadosBase];
      novosChamados[idx] = chamado;
      _chamadosBase = novosChamados;
      _atualizarListaProcessada();

      if (antigo.status != chamado.status) {
        ref.read(notificacaoProvider).adicionarNotificacao(
          'Status do chamado "${chamado.titulo}" alterado para "${chamado.status}".',
        );
      } else {
        ref.read(notificacaoProvider).adicionarNotificacao(
          'Chamado "${chamado.titulo}" atualizado.',
        );
      }
    }
  }

  Future<void> alternarFavorito(Chamado chamado) async {
    final atualizado = chamado.copyWith(favorito: !chamado.favorito);
    await DbHelper.instance.updateFavorito(
      chamado.id!,
      atualizado.favorito ? 1 : 0,
    );

    final idx = _chamadosBase.indexWhere((c) => c.id == chamado.id);
    if (idx != -1) {
      final novos = [..._chamadosBase];
      novos[idx] = atualizado;
      _chamadosBase = novos;
      _atualizarListaProcessada();

      final prefixo = 'Favorito: "${chamado.titulo}"';
      if (atualizado.favorito) {
        await ref.read(notificacaoProvider).adicionarNotificacao(
          '$prefixo marcado como favorito.',
        );
      } else {
        await ref.read(notificacaoProvider).removerNotificacaoPorMensagem(prefixo);
      }
    }
  }
}
