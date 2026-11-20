import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/info_linha.dart';
import '../models/registro.dart';
import '../provider/registros.dart';
import '../utils/formatadores.dart';

/// Detalhes de um registro: foto e informações associadas, com a opção
/// de excluir (RF05).
class RegistroDetail extends StatelessWidget {
  final Registro registro;

  const RegistroDetail({super.key, required this.registro});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(registro.titulo, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Excluir registro',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          Hero(
            tag: 'foto_${registro.id}',
            child: Image.file(
              File(registro.caminhoFoto),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 240,
                color: tema.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: Text('Arquivo da foto não encontrado'),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(registro.titulo, style: tema.textTheme.headlineSmall),
                if (registro.descricao.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(registro.descricao, style: tema.textTheme.bodyLarge),
                ],
                const Divider(height: 32),
                InfoLinha(
                  icone: Icons.calendar_today,
                  rotulo: 'Data',
                  valor: formatarData(registro.dataHora),
                ),
                InfoLinha(
                  icone: Icons.schedule,
                  rotulo: 'Hora',
                  valor: formatarHora(registro.dataHora),
                ),
                InfoLinha(
                  icone: Icons.north,
                  rotulo: 'Latitude',
                  valor: registro.latitude.toStringAsFixed(6),
                ),
                InfoLinha(
                  icone: Icons.east,
                  rotulo: 'Longitude',
                  valor: registro.longitude.toStringAsFixed(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Confirma a exclusão. Por padrão o arquivo da foto também é apagado;
  /// o usuário pode optar por mantê-lo no aparelho.
  Future<void> _confirmarExclusao(BuildContext context) async {
    var excluirFoto = true;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Excluir registro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deseja excluir "${registro.titulo}"?'),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: excluirFoto,
                onChanged: (v) => setStateDialog(() => excluirFoto = v ?? true),
                title: const Text('Apagar também o arquivo da foto'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ),
    );

    if (confirmou != true || !context.mounted) return;
    await context.read<Registros>().excluir(registro, excluirFoto: excluirFoto);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro excluído')),
    );
  }
}
