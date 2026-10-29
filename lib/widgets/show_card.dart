import 'package:flutter/material.dart';

import '../models/show.dart';
import 'show_poster.dart';

/// Card de uma serie nos resultados da pesquisa.
class ShowCard extends StatelessWidget {
  const ShowCard({
    super.key,
    required this.show,
    required this.inWatchlist,
    required this.onTap,
  });

  final Show show;
  final bool inWatchlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final detalhes = [
      if (show.year != null) show.year!,
      if (show.genres.isNotEmpty) show.genres.join(', '),
    ].join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ShowPoster(imageUrl: show.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      show.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (detalhes.isNotEmpty)
                      Text(
                        detalhes,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(show.rating?.toStringAsFixed(1) ?? 'Sem nota'),
                      ],
                    ),
                  ],
                ),
              ),
              if (inWatchlist)
                Tooltip(
                  message: 'Na minha lista',
                  child: Icon(
                    Icons.bookmark,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
