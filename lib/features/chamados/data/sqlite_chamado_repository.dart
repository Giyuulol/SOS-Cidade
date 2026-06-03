import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../domain/chamado.dart';
import '../domain/chamado_enums.dart';
import '../domain/chamado_repository.dart';

final class SqliteChamadoRepository implements ChamadoRepository {
  static const _databaseName = 'sos_cidade.db';
  static const _tableName = 'chamados';

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, _databaseName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE $_tableName (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  categoria TEXT NOT NULL,
  prioridade TEXT NOT NULL,
  bairro TEXT NOT NULL,
  responsavel TEXT NOT NULL,
  data TEXT NOT NULL,
  status TEXT NOT NULL
)
''');
      },
    );

    return _database!;
  }

  @override
  Future<List<Chamado>> findAll() async {
    final db = await _db;
    final rows = await db.query(_tableName, orderBy: 'data DESC');
    return rows.map(_fromMap).toList(growable: false);
  }

  @override
  Future<Chamado> create(Chamado chamado) async {
    final db = await _db;
    final id = await db.insert(_tableName, _toMap(chamado));
    return chamado.copyWith(id: id);
  }

  @override
  Future<void> updateStatus({
    required int chamadoId,
    required ChamadoStatus status,
  }) async {
    final db = await _db;
    await db.update(
      _tableName,
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [chamadoId],
    );
  }

  @override
  Future<void> ensureSeedData() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );

    if ((count ?? 0) > 0) return;

    final now = DateTime.now();
    final seed = [
      Chamado(
        titulo: 'Vazamento na Avenida Central',
        descricao: 'Água escorrendo pela via principal desde cedo.',
        categoria: ChamadoCategoria.saneamento,
        prioridade: ChamadoPrioridade.alta,
        bairro: 'Centro',
        responsavel: 'Equipe Hidráulica',
        data: now.subtract(const Duration(hours: 2)),
        status: ChamadoStatus.aberto,
      ),
      Chamado(
        titulo: 'Semáforo sem funcionar',
        descricao: 'Cruzamento com risco de acidente no horário de pico.',
        categoria: ChamadoCategoria.transito,
        prioridade: ChamadoPrioridade.critica,
        bairro: 'São José',
        responsavel: 'Trânsito',
        data: now.subtract(const Duration(hours: 4)),
        status: ChamadoStatus.emAndamento,
      ),
      Chamado(
        titulo: 'Lixo acumulado perto da escola',
        descricao: 'Moradores relataram mau cheiro e obstrução da calçada.',
        categoria: ChamadoCategoria.limpezaUrbana,
        prioridade: ChamadoPrioridade.media,
        bairro: 'Jardim Cidade Universitária',
        responsavel: 'Limpeza Urbana',
        data: now.subtract(const Duration(days: 1)),
        status: ChamadoStatus.aberto,
      ),
      Chamado(
        titulo: 'Árvore caiu após chuva',
        descricao: 'Galhos bloqueiam parte da rua e acesso de veículos.',
        categoria: ChamadoCategoria.desastreNatural,
        prioridade: ChamadoPrioridade.critica,
        bairro: 'Portal do Sol',
        responsavel: 'Defesa Civil',
        data: now.subtract(const Duration(days: 2)),
        status: ChamadoStatus.concluido,
      ),
    ];

    for (final chamado in seed) {
      await db.insert(_tableName, _toMap(chamado));
    }
  }

  Map<String, Object?> _toMap(Chamado chamado) {
    return {
      'titulo': chamado.titulo,
      'descricao': chamado.descricao,
      'categoria': chamado.categoria.name,
      'prioridade': chamado.prioridade.name,
      'bairro': chamado.bairro,
      'responsavel': chamado.responsavel,
      'data': chamado.data.toIso8601String(),
      'status': chamado.status.name,
    };
  }

  Chamado _fromMap(Map<String, Object?> map) {
    return Chamado(
      id: map['id'] as int,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      categoria: _categoryFromStorage(map['categoria'] as String),
      prioridade: ChamadoPrioridade.values.byName(map['prioridade'] as String),
      bairro: map['bairro'] as String,
      responsavel: map['responsavel'] as String,
      data: DateTime.parse(map['data'] as String),
      status: ChamadoStatus.values.byName(map['status'] as String),
    );
  }

  ChamadoCategoria _categoryFromStorage(String value) {
    return switch (value) {
      'vazamentoAgua' => ChamadoCategoria.saneamento,
      'acidente' => ChamadoCategoria.transito,
      'semaforoQuebrado' => ChamadoCategoria.transito,
      'lixoAcumulado' => ChamadoCategoria.limpezaUrbana,
      'arvoreCaida' => ChamadoCategoria.desastreNatural,
      'enchente' => ChamadoCategoria.desastreNatural,
      _ => ChamadoCategoria.values.byName(value),
    };
  }
}
