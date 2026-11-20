import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/registro.dart';
import '../services/photo_service.dart';

/// Provider que mantém a lista de registros em memória, sincronizada com
/// o banco SQLite. Notifica a interface a cada alteração.
class Registros with ChangeNotifier {
  final DatabaseHelper _db;
  final PhotoService _fotos;
  final List<Registro> _items = [];
  bool _carregando = true;

  Registros({DatabaseHelper? db, PhotoService? fotos})
      : _db = db ?? DatabaseHelper(),
        _fotos = fotos ?? PhotoService() {
    carregar();
  }

  /// Cópia da lista para evitar modificações externas.
  List<Registro> get all => [..._items];
  int get itemCount => _items.length;
  Registro registroAt(int index) => _items[index];
  bool get carregando => _carregando;

  /// Consulta (R do CRUD): lê todos os registros do banco.
  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    final lista = await _db.listar();
    _items
      ..clear()
      ..addAll(lista);
    _carregando = false;
    notifyListeners();
  }

  /// Inclusão (C do CRUD).
  Future<Registro> adicionar(Registro registro) async {
    final id = await _db.inserir(registro);
    final salvo = registro.copyWith(id: id);
    _items.insert(0, salvo); // mais recente primeiro, como na consulta
    notifyListeners();
    return salvo;
  }

  /// Exclusão (D do CRUD): remove a linha do banco e, se pedido,
  /// também o arquivo da foto no armazenamento local.
  Future<void> excluir(Registro registro, {bool excluirFoto = true}) async {
    if (registro.id == null) return;
    await _db.excluir(registro.id!);
    if (excluirFoto) {
      await _fotos.excluirArquivo(registro.caminhoFoto);
    }
    _items.removeWhere((r) => r.id == registro.id);
    notifyListeners();
  }
}
