import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Captura fotos pela câmera e cuida dos arquivos no armazenamento local.
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// Abre a câmera do aparelho. Devolve `null` se o usuário cancelar.
  Future<XFile?> capturarFoto() {
    return _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      imageQuality: 85,
    );
  }

  /// No Android o sistema pode encerrar o app enquanto a câmera está aberta.
  /// Ao voltar, recuperamos aqui a foto que já tinha sido tirada.
  Future<XFile?> recuperarFotoPerdida() async {
    final resposta = await _picker.retrieveLostData();
    if (resposta.isEmpty) return null;
    return resposta.file;
  }

  /// A foto do image_picker fica numa pasta temporária (cache), que o sistema
  /// pode limpar. Por isso ela é copiada para a pasta de documentos do app.
  Future<String> salvarNoArmazenamentoLocal(XFile foto) async {
    final documentos = await getApplicationDocumentsDirectory();
    final pasta = Directory(p.join(documentos.path, 'fotos'));
    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }
    final extensao = p.extension(foto.path).isEmpty
        ? '.jpg'
        : p.extension(foto.path);
    final nome = 'geodiario_${DateTime.now().millisecondsSinceEpoch}$extensao';
    final destino = p.join(pasta.path, nome);
    await File(foto.path).copy(destino);
    return destino;
  }

  /// Remove o arquivo da foto, se ele ainda existir.
  Future<void> excluirArquivo(String caminho) async {
    final arquivo = File(caminho);
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }
}
