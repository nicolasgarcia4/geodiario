import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../components/info_linha.dart';
import '../models/registro.dart';
import '../provider/registros.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../utils/formatadores.dart';

/// Tela de novo registro: tira a foto (RF01), associa data/hora e GPS
/// automaticamente e recebe título e descrição do usuário (RF02).
class RegistroForm extends StatefulWidget {
  const RegistroForm({super.key});

  @override
  State<RegistroForm> createState() => _RegistroFormState();
}

class _RegistroFormState extends State<RegistroForm> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _fotos = PhotoService();
  final _localizacao = LocationService();

  XFile? _foto;
  DateTime? _dataHora;
  Position? _posicao;
  String? _erroLocalizacao;
  bool _buscandoLocalizacao = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _recuperarFotoPerdida();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _recuperarFotoPerdida() async {
    final foto = await _fotos.recuperarFotoPerdida();
    if (foto != null) _definirFoto(foto);
  }

  Future<void> _tirarFoto() async {
    try {
      final foto = await _fotos.capturarFoto();
      if (foto != null) _definirFoto(foto);
    } catch (e) {
      _mostrarMensagem('Não foi possível abrir a câmera: $e');
    }
  }

  /// A data/hora é a do momento da foto; o GPS é buscado logo em seguida.
  void _definirFoto(XFile foto) {
    setState(() {
      _foto = foto;
      _dataHora = DateTime.now();
    });
    _buscarLocalizacao();
  }

  Future<void> _buscarLocalizacao() async {
    setState(() {
      _buscandoLocalizacao = true;
      _erroLocalizacao = null;
    });
    try {
      final posicao = await _localizacao.obterPosicaoAtual();
      if (!mounted) return;
      setState(() => _posicao = posicao);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroLocalizacao = e is LocalizacaoException
          ? e.mensagem
          : 'Erro ao obter localização: $e');
    } finally {
      if (mounted) setState(() => _buscandoLocalizacao = false);
    }
  }

  Future<void> _salvar() async {
    if (_foto == null) {
      _mostrarMensagem('Tire uma foto antes de salvar.');
      return;
    }
    if (_posicao == null) {
      _mostrarMensagem('Aguarde a localização do GPS.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final caminho = await _fotos.salvarNoArmazenamentoLocal(_foto!);
      final registro = Registro(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        caminhoFoto: caminho,
        dataHora: _dataHora!,
        latitude: _posicao!.latitude,
        longitude: _posicao!.longitude,
      );
      if (!mounted) return;
      await context.read<Registros>().adicionar(registro);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro salvo!')),
      );
    } catch (e) {
      _mostrarMensagem('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final podeSalvar = _foto != null && _posicao != null && !_salvando;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo registro')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _areaFoto(),
            const SizedBox(height: 8),
            if (_dataHora != null) ...[
              InfoLinha(
                icone: Icons.event,
                rotulo: 'Data e hora',
                valor: formatarDataHora(_dataHora!),
              ),
              _linhaLocalizacao(),
            ],
            const SizedBox(height: 8),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ex.: Pôr do sol na Praça da Liberdade',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 60,
              validator: (valor) => (valor == null || valor.trim().isEmpty)
                  ? 'Informe um título'
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              maxLength: 280,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: podeSalvar ? _salvar : null,
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Salvar registro'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _areaFoto() {
    final tema = Theme.of(context);
    if (_foto == null) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: OutlinedButton(
          onPressed: _tirarFoto,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_camera, size: 56, color: tema.colorScheme.primary),
              const SizedBox(height: 8),
              const Text('Tirar foto'),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(File(_foto!.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: FilledButton.tonalIcon(
            onPressed: _tirarFoto,
            icon: const Icon(Icons.refresh),
            label: const Text('Tirar outra'),
          ),
        ),
      ],
    );
  }

  Widget _linhaLocalizacao() {
    if (_buscandoLocalizacao) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Obtendo localização pelo GPS...'),
      );
    }
    if (_erroLocalizacao != null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.location_off,
            color: Theme.of(context).colorScheme.error),
        title: Text(_erroLocalizacao!),
        trailing: TextButton(
          onPressed: _buscarLocalizacao,
          child: const Text('Tentar de novo'),
        ),
      );
    }
    if (_posicao == null) return const SizedBox.shrink();
    return InfoLinha(
      icone: Icons.location_on,
      rotulo: 'Latitude, longitude',
      valor: formatarCoordenadas(_posicao!.latitude, _posicao!.longitude),
    );
  }
}
