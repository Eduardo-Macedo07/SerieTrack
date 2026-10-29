import 'package:flutter/material.dart';

/// Capa da serie. Se nao houver imagem ou ela falhar, mostra um icone.
class ShowPoster extends StatelessWidget {
  const ShowPoster({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 85,
  });

  final String? imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.tv, size: 32),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl == null
          ? placeholder
          : Image.network(
              imageUrl!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}
