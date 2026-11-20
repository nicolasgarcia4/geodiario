import 'package:flutter/material.dart';

/// Linha de informação com ícone, rótulo e valor (usada no formulário e
/// na tela de detalhes).
class InfoLinha extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const InfoLinha({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icone, color: tema.colorScheme.primary),
      title: Text(rotulo, style: tema.textTheme.labelMedium),
      subtitle: Text(valor, style: tema.textTheme.bodyLarge),
    );
  }
}
