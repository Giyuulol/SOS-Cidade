import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../database/db_helper.dart';

class Notificacao {
  const Notificacao({
    this.id,
    required this.mensagem,
    this.lido = false,
    required this.data,
  });

  final int? id;
  final String mensagem;
  final bool lido;
  final DateTime data;

  Notificacao copyWith({
    int? id,
    String? mensagem,
    bool? lido,
    DateTime? data,
  }) {
    return Notificacao(
      id: id ?? this.id,
      mensagem: mensagem ?? this.mensagem,
      lido: lido ?? this.lido,
      data: data ?? this.data,
    );
  }

  factory Notificacao.fromMap(Map<String, Object?> map) {
    return Notificacao(
      id: map['id'] as int?,
      mensagem: map['mensagem'] as String,
      lido: (map['lido'] as int? ?? 0) == 1,
      data: DateTime.parse(map['data'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'mensagem': mensagem,
      'lido': lido ? 1 : 0,
      'data': data.toIso8601String(),
    };
  }
}

final notificacaoProvider = ChangeNotifierProvider<NotificacaoProvider>((ref) {
  final provider = NotificacaoProvider();
  provider.carregarNotificacoes();
  return provider;
});

class NotificacaoProvider extends ChangeNotifier {
  List<Notificacao> _notificacoes = [];

  List<Notificacao> get notificacoes => _notificacoes;
  int get naoLidas => _notificacoes.where((n) => !n.lido).length;

  Future<void> carregarNotificacoes() async {
    try {
      final rows = await DbHelper.instance.fetchNotificacoes();
      _notificacoes = rows
          .map((m) => Notificacao.fromMap(Map<String, Object?>.from(m)))
          .toList();
      notifyListeners();
    } catch (_) {
      // Ignora erro se o banco de dados não estiver inicializado (como em testes)
    }
  }

  Future<void> adicionarNotificacao(String mensagem) async {
    final nova = Notificacao(
      mensagem: mensagem,
      data: DateTime.now(),
    );
    final map = nova.toMap();
    map.remove('id');

    final id = await DbHelper.instance.insertNotificacao(
      Map<String, dynamic>.from(map),
    );
    if (id > 0) {
      _notificacoes = [nova.copyWith(id: id), ..._notificacoes];
      notifyListeners();
    }
  }

  Future<void> marcarTodasComoLidas() async {
    await DbHelper.instance.marcarNotificacoesComoLidas();
    _notificacoes = _notificacoes.map((n) => n.copyWith(lido: true)).toList();
    notifyListeners();
  }

  Future<void> excluirNotificacao(int id) async {
    await DbHelper.instance.deleteNotificacao(id);
    _notificacoes = _notificacoes.where((n) => n.id != id).toList();
    notifyListeners();
  }

  Future<void> removerNotificacaoPorMensagem(String prefixo) async {
    final paraRemover = _notificacoes.where((n) => n.mensagem.startsWith(prefixo)).toList();
    for (final n in paraRemover) {
      if (n.id != null) {
        await DbHelper.instance.deleteNotificacao(n.id!);
      }
    }
    _notificacoes = _notificacoes.where((n) => !n.mensagem.startsWith(prefixo)).toList();
    notifyListeners();
  }
}
