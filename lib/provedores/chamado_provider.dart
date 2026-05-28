import 'package:flutter/material.dart';
import '../models/chamado.dart';
import '../database/db_helper.dart';

class ChamadoProvider extends ChangeNotifier {
  List<Chamado> _chamados = [];

  List<Chamado> get chamados {
    final agora = DateTime.now();

    List<Chamado> listaFiltrada = _chamados.where((c) {
      if (c.status.toLowerCase() == 'concluído') {
        final horasDesdeFechamento = agora
            .difference(c.dataAbertura)
            .inHours; // fallback
        return horasDesdeFechamento < 12;
      }
      return true;
    }).toList();

    listaFiltrada.sort((a, b) {
      int peso(String p) {
        switch (p.toLowerCase()) {
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

      return peso(b.prioridade).compareTo(peso(a.prioridade));
    });
    return listaFiltrada;
  }

  int get total => chamados.length;
  int get abertos => chamados.where((c) => c.status == 'Aberto').length;
  int get emAndamento =>
      chamados.where((c) => c.status == 'Em Andamento').length;
  int get concluidos => chamados.where((c) => c.status == 'Concluído').length;
  int get criticos => chamados.where((c) => c.prioridade == 'Crítica').length;

  bool get exibirAlertaCritico =>
      chamados
          .where((c) => c.prioridade == 'Crítica' && c.status != 'Concluído')
          .length >
      5;

  Future<void> carregarChamados() async {
    final rows = await DbHelper.instance.fetchChamados();
    _chamados = rows
        .map((m) => Chamado.fromMap(Map<String, Object?>.from(m)))
        .toList();
    notifyListeners();
  }

  bool existeTituloRepetido(String titulo, {int? idIgnorar}) {
    return _chamados.any(
      (c) =>
          c.titulo.trim().toLowerCase() == titulo.trim().toLowerCase() &&
          c.id != idIgnorar,
    );
  }

  Future<bool> adicionarChamado(Chamado chamado) async {
    if (existeTituloRepetido(chamado.titulo)) return false;
    final map = chamado.toMap();
    // remove id to allow AUTOINCREMENT
    map.remove('id');
    final id = await DbHelper.instance.insertChamado(
      Map<String, dynamic>.from(map),
    );
    if (id > 0) {
      final novo = chamado.copyWith(id: id);
      _chamados.add(novo);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> atualizarChamado(Chamado chamado) async {
    final idx = _chamados.indexWhere((c) => c.id == chamado.id);
    if (idx != -1) {
      await DbHelper.instance.updateChamado(
        chamado.toMap().map((k, v) => MapEntry(k, v)),
      );
      _chamados[idx] = chamado;
      notifyListeners();
    }
  }

  // persistence now handled by DbHelper
}
