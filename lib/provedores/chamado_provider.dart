import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/chamado.dart';
import '../database/db_helper.dart';

final chamadoProvider = ChangeNotifierProvider<ChamadoProvider>((ref) {
  final provider = ChamadoProvider();
  provider.carregarChamados();
  return provider;
});

class ChamadoProvider extends ChangeNotifier {
  List<Chamado> _chamadosBase = [];
  List<Chamado> _chamadosProcessados = [];

  List<Chamado> get chamados => _chamadosProcessados;

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

  void _atualizarListaProcessada() {
    final listaOrdenada = List<Chamado>.from(_chamadosBase);

    listaOrdenada.sort((a, b) {
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

    _chamadosProcessados = listaOrdenada;
    notifyListeners();
  }

  Future<void> carregarChamados() async {
    final rows = await DbHelper.instance.fetchChamados();
    _chamadosBase = rows
        .map((m) => Chamado.fromMap(Map<String, Object?>.from(m)))
        .toList();
    _atualizarListaProcessada();
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
      return true;
    }
    return false;
  }

  Future<void> atualizarChamado(Chamado chamado) async {
    final idx = _chamadosBase.indexWhere((c) => c.id == chamado.id);
    if (idx != -1) {
      await DbHelper.instance.updateChamado(
        chamado.toMap().map((k, v) => MapEntry(k, v)),
      );
      final novosChamados = [..._chamadosBase];
      novosChamados[idx] = chamado;
      _chamadosBase = novosChamados;

      _atualizarListaProcessada();
    }
  }
}
