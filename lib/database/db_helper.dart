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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chamados(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT UNIQUE NOT NULL,
        descricao TEXT NOT NULL,
        categoria TEXT NOT NULL,
        prioridade TEXT NOT NULL,
        bairro TEXT NOT NULL,
        responsavel TEXT NOT NULL,
        status TEXT NOT NULL,
        dataAbertura TEXT NOT NULL,
        favorito INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        chave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notificacoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mensagem TEXT NOT NULL,
        lido INTEGER DEFAULT 0,
        data TEXT NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add favorito column to chamados table
      await db.execute('ALTER TABLE chamados ADD COLUMN favorito INTEGER DEFAULT 0');

      // Create settings table
      await db.execute('''
        CREATE TABLE settings(
          chave TEXT PRIMARY KEY,
          valor TEXT NOT NULL
        )
      ''');

      // Create notificacoes table
      await db.execute('''
        CREATE TABLE notificacoes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mensagem TEXT NOT NULL,
          lido INTEGER DEFAULT 0,
          data TEXT NOT NULL
        )
      ''');
    }
  }

  Future<int> insertChamado(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('chamados', row);
  }

  Future<int> updateChamado(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'] as int?;
    if (id == null) return 0;

    final chamadoAtual = await db.query(
      'chamados',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (chamadoAtual.isNotEmpty &&
        chamadoAtual.first['status'].toString().toLowerCase() == 'concluído') {
      throw Exception('Não é possível editar um chamado concluído.');
    }

    return await db.update('chamados', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateFavorito(int id, int favoritoValue) async {
    final db = await instance.database;
    return await db.update(
      'chamados',
      {'favorito': favoritoValue},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> fetchChamados() async {
    final db = await instance.database;
    return await db.query('chamados');
  }

  // --- Settings ---
  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final res = await db.query('settings', where: 'chave = ?', whereArgs: [key]);
    if (res.isEmpty) return null;
    return res.first['valor'] as String?;
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      {'chave': key, 'valor': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Notifications ---
  Future<int> insertNotificacao(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('notificacoes', row);
  }

  Future<List<Map<String, dynamic>>> fetchNotificacoes() async {
    final db = await instance.database;
    return await db.query('notificacoes', orderBy: 'data DESC');
  }

  Future<int> marcarNotificacoesComoLidas() async {
    final db = await instance.database;
    return await db.update('notificacoes', {'lido': 1}, where: 'lido = ?', whereArgs: [0]);
  }

  Future<int> deleteNotificacao(int id) async {
    final db = await instance.database;
    return await db.delete('notificacoes', where: 'id = ?', whereArgs: [id]);
  }
}
