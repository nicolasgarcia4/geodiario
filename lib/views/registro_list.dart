import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/registro_card.dart';
import '../provider/registros.dart';
import 'registro_detail.dart';
import 'registro_form.dart';

/// Tela inicial: galeria com todos os registros salvos (RF04).
class RegistroList extends StatelessWidget {
  const RegistroList({super.key});

  @override
  Widget build(BuildContext context) {
    final registros = Provider.of<Registros>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoDiário'),
        actions: [
          if (registros.itemCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  registros.itemCount == 1
                      ? '1 registro'
                      : '${registros.itemCount} registros',
                ),
              ),
            ),
        ],
      ),
      body: _corpo(context, registros),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RegistroForm()),
        ),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Novo registro'),
      ),
    );
  }

  Widget _corpo(BuildContext context, Registros registros) {
    if (registros.carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (registros.itemCount == 0) {
      return const _ListaVazia();
    }
    return RefreshIndicator(
      onRefresh: registros.carregar,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.78,
        ),
        itemCount: registros.itemCount,
        itemBuilder: (context, index) {
          final registro = registros.registroAt(index);
          return RegistroCard(
            registro: registro,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RegistroDetail(registro: registro),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ListaVazia extends StatelessWidget {
  const _ListaVazia();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_outlined,
                size: 72, color: tema.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Nenhum registro ainda', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Toque em "Novo registro" para fotografar um lugar. '
              'A data, a hora e a localização são salvas automaticamente.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
