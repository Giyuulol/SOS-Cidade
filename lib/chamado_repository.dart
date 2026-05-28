import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atividade/models/chamado_model.dart';

class ChamadoRepository {
  static const String _storageKey = 'sos_cidade_chamados';

  Future<List<Chamado>> buscarChamados() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => Chamado.fromMap(item)).toList();
  }

  Future<void> salvarLista(List<Chamado> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(lista.map((c) => c.toMap()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
