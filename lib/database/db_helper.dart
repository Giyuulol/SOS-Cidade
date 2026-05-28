import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();

  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('sos_cidade.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chamados(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        descricao TEXT,
        categoria TEXT,
        prioridade TEXT,
        bairro TEXT,
        responsavel TEXT,
        status TEXT,
        dataAbertura TEXT
      )
    ''');
  }

  Future<int> insertChamado(Map<String, dynamic> row) async {
    final db = await instance.database;

    return await db.insert('chamados', row);
  }

  Future<int> updateChamado(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'] as int?;
    if (id == null) return 0;
    return await db.update('chamados', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteChamado(int id) async {
    final db = await instance.database;
    return await db.delete('chamados', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> fetchChamados() async {
    final db = await instance.database;

    return await db.query('chamados');
  }
}
