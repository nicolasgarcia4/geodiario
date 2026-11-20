import 'dart:io';

import 'package:flutter/material.dart';

import '../models/registro.dart';
import '../utils/formatadores.dart';

/// Card da galeria: miniatura da foto, título e data do registro.
class RegistroCard extends StatelessWidget {
  final Registro registro;
  final VoidCallback onTap;

  const RegistroCard({super.key, required this.registro, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'foto_${registro.id}',
                child: Image.file(
                  File(registro.caminhoFoto),
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: tema.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image_outlined, size: 40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registro.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 14, color: tema.colorScheme.outline),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formatarDataHora(registro.dataHora),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
