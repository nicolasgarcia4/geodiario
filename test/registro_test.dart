import 'package:flutter_test/flutter_test.dart';
import 'package:geodiario/data/database_helper.dart';
import 'package:geodiario/models/registro.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Registro _exemplo(String titulo, DateTime dataHora) => Registro(
      titulo: titulo,
      descricao: 'Descrição de $titulo',
      caminhoFoto: '/fotos/$titulo.jpg',
      dataHora: dataHora,
      latitude: -19.9321,
      longitude: -43.9386,
    );

void main() {
  // SQLite real (via FFI) rodando no computador, sem emulador.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Registro', () {
    test('toMap/fromMap preservam todos os campos', () {
      final original = _exemplo('praca', DateTime(2026, 11, 20, 14, 5));
      final copia = Registro.fromMap({...original.toMap(), 'id': 7});
      expect(copia.id, 7);
      expect(copia.titulo, original.titulo);
      expect(copia.descricao, original.descricao);
      expect(copia.caminhoFoto, original.caminhoFoto);
      expect(copia.dataHora, original.dataHora);
      expect(copia.latitude, original.latitude);
      expect(copia.longitude, original.longitude);
    });

    test('toMap não envia id na inclusão', () {
      expect(_exemplo('a', DateTime(2026)).toMap().containsKey('id'), isFalse);
    });
  });

  group('DatabaseHelper', () {
    late DatabaseHelper db;

    setUp(() => db = DatabaseHelper(caminhoBanco: inMemoryDatabasePath));
    tearDown(() => db.fechar());

    test('inclui, consulta (mais recente primeiro) e exclui', () async {
      final id1 = await db.inserir(_exemplo('antigo', DateTime(2026, 11, 1)));
      final id2 = await db.inserir(_exemplo('novo', DateTime(2026, 11, 20)));
      expect(id2, greaterThan(id1));

      var lista = await db.listar();
      expect(lista.map((r) => r.titulo), ['novo', 'antigo']);
      expect(lista.first.latitude, -19.9321);

      expect(await db.excluir(id1), 1);
      lista = await db.listar();
      expect(lista.map((r) => r.id), [id2]);
      expect(await db.buscarPorId(id1), isNull);
    });
  });
}
