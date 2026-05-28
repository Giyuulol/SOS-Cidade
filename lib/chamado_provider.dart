import 'package:flutter/material.dart';
import 'package:atividade/models/chamado_model.dart';
import 'package:atividade/repositories/chamado_repository.dart';

class ChamadoProvider with ChangeNotifier {
  final ChamadoRepository _repository = ChamadoRepository();
  List<Chamado> _chamados = [];

  List<Chamado> get chamados {
    final agora = DateTime.now();

    List<Chamado> listaFiltrada = _chamados.where((c) {
      if (c.status == 'concluído') {
        final horasDesdeFechamento =
            agora.difference(c.dataUltimaAtualizacao).inHours;
        return horasDesdeFechamento < 12;
      }
      return true;
    }).toList();

    listaFiltrada.sort((a, b) {
      int peso(String p) {
        if (p == 'crítica') return 4;
        if (p == 'alta') return 3;
        if (p == 'média') return 2;
        return 1;
      }

      return peso(b.prioridade).compareTo(peso(a.prioridade));
    });
    return listaFiltrada;
  }

  int get total => chamados.length;
  int get abertos => chamados.where((c) => c.status == 'aberto').length;
  int get emAndamento =>
      chamados.where((c) => c.status == 'em andamento').length;
  int get concluidos => chamados.where((c) => c.status == 'concluído').length;
  int get criticos => chamados.where((c) => c.prioridade == 'crítica').length;

  bool get exibirAlertaCritico =>
      chamados
          .where((c) => c.prioridade == 'crítica' && c.status != 'concluído')
          .length >
      5;

  Future<void> carregarChamados() async {
    _chamados = await _repository.buscarChamados();
    notifyListeners();
  }

  bool existeTituloRepetido(String titulo, {String? idIgnorar}) {
    return _chamados.any((c) =>
        c.titulo.trim().toLowerCase() == titulo.trim().toLowerCase() &&
        c.id != idIgnorar);
  }

  Future<bool> adicionarChamado(Chamado chamado) async {
    if (existeTituloRepetido(chamado.titulo)) return false;
    _chamados.add(chamado);
    await _repository.salvarLista(_chamados);
    notifyListeners();
    return true;
  }

  Future<void> atualizarChamado(String id, Atualizacao novaAtualizacao) async {
    final index = _chamados.indexWhere((c) => c.id == id);
    if (index != -1) {
      final antigo = _chamados[index];

      final chamadoAtualizado = Chamado(
        id: antigo.id,
        titulo: antigo.titulo,
        descricao: antigo.descricao,
        categoria: antigo.categoria,
        prioridade: antigo.prioridade,
        bairro: antigo.bairro,
        responsavelOriginal: antigo.responsavelOriginal,
        dataAbertura: antigo.dataAbertura,
        status: novaAtualizacao.statusAlterado,
        dataUltimaAtualizacao: DateTime.now(),
        historico: List.from(antigo.historico)..add(novaAtualizacao),
      );

      _chamados[index] = chamadoAtualizado;
      await _repository.salvarLista(_chamados);
      notifyListeners();
    }
  }
}
