import 'package:geolocator/geolocator.dart';

/// Erro com uma mensagem pronta para mostrar ao usuário.
class LocalizacaoException implements Exception {
  final String mensagem;
  LocalizacaoException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Obtém as coordenadas do GPS seguindo o fluxo do material de apoio:
/// serviço ativo → permissão → posição atual com alta precisão.
class LocationService {
  Future<Position> obterPosicaoAtual() async {
    // 1. Verifica se o serviço de localização do aparelho está ativo
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw LocalizacaoException(
        'O GPS/serviço de localização está desativado no dispositivo.',
      );
    }

    // 2. Verifica (e, se preciso, solicita) a permissão
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        throw LocalizacaoException('Permissão de localização negada.');
      }
    }

    // 3. Permissão negada permanentemente: só pelas configurações
    if (permissao == LocationPermission.deniedForever) {
      throw LocalizacaoException(
        'A permissão de localização está negada permanentemente. '
        'Ative-a nas configurações do aparelho.',
      );
    }

    // 4. Captura a posição atual com precisão alta
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  /// Abre as configurações do app (útil quando a permissão foi negada).
  Future<bool> abrirConfiguracoes() => Geolocator.openAppSettings();
}
