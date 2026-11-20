import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/registro.dart';

/// Acesso ao banco SQLite (sqflite): criação da tabela e operações
/// de inclusão, consulta e exclusão dos registros.
class DatabaseHelper {
  static const _nomeBanco = 'geodiario.db';
  static const tabela = 'registros';

  /// Instrução de criação da tabela (também documentada no README).
  static const sqlCriarTabela = '''
    CREATE TABLE $tabela(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      titulo TEXT NOT NULL,
      descricao TEXT,
      caminho_foto TEXT NOT NULL,
      data_hora TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL
    )
  ''';

  Database? _db;

  /// Caminho opcional usado nos testes (ex.: `inMemoryDatabasePath`).
  final String? caminhoBanco;

  DatabaseHelper({this.caminhoBanco});

  Future<Database> get database async {
    return _db ??= await _abrirBanco();
  }

  Future<Database> _abrirBanco() async {
    final path = caminhoBanco ?? join(await getDatabasesPath(), _nomeBanco);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute(sqlCriarTabela),
    );
  }

  /// Insere um registro e devolve o id gerado pelo SQLite.
  Future<int> inserir(Registro registro) async {
    final db = await database;
    return db.insert(tabela, registro.toMap());
  }

  /// Lista todos os registros, do mais recente para o mais antigo.
  Future<List<Registro>> listar() async {
    final db = await database;
    final maps = await db.query(tabela, orderBy: 'data_hora DESC');
    return maps.map(Registro.fromMap).toList();
  }

  Future<Registro?> buscarPorId(int id) async {
    final db = await database;
    final maps = await db.query(tabela, where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : Registro.fromMap(maps.first);
  }

  /// Exclui o registro e devolve quantas linhas foram removidas.
  Future<int> excluir(int id) async {
    final db = await database;
    return db.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> fechar() async {
    await _db?.close();
    _db = null;
  }
}
