import 'package:flutter/material.dart';

import '../models/watch_item.dart';
import '../services/show_service.dart';
import '../state/watchlist_controller.dart';
import '../widgets/rating_stars.dart';
import '../widgets/request_state_views.dart';
import '../widgets/show_poster.dart';
import 'details_screen.dart';

/// Lista pessoal: resumo, filtro por status, remocao com "desfazer".
class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({
    super.key,
    required this.service,
    required this.watchlist,
  });

  final ShowService service;
  final WatchlistController watchlist;

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  /// null = mostrar todos os status.
  WatchStatus? _filter;

  void _remove(WatchItem item) {
    widget.watchlist.remove(item.show.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${item.show.name}" removida.'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => widget.watchlist.restore(item),
          ),
        ),
      );
  }

  void _openDetails(WatchItem item) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetailsScreen(
          show: item.show,
          service: widget.service,
          watchlist: widget.watchlist,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha lista')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.watchlist,
          builder: (context, _) {
            if (widget.watchlist.count == 0) {
              return const EmptyView(
                icon: Icons.bookmark_border,
                message: 'Sua lista esta vazia.\n'
                    'Pesquise uma serie e toque em "Adicionar a minha lista".',
              );
            }

            final items = widget.watchlist.byStatus(_filter);

            return Column(
              children: [
                _SummaryCard(watchlist: widget.watchlist),
                SizedBox(
                  height: 48,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('Todos'),
                          selected: _filter == null,
                          onSelected: (_) => setState(() => _filter = null),
                        ),
                      ),
                      ...WatchStatus.values.map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            key: Key('statusFilter_${status.name}'),
                            label: Text(status.label),
                            selected: _filter == status,
                            onSelected: (_) => setState(() => _filter = status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? EmptyView(
                          icon: Icons.filter_alt_off,
                          message: 'Nenhuma serie com status '
                              '"${_filter?.label}".',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Dismissible(
                              key: ValueKey(item.show.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _remove(item),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Theme.of(context).colorScheme.error,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: Card(
                                child: ListTile(
                                  key: Key('watchItem_${item.show.id}'),
                                  onTap: () => _openDetails(item),
                                  leading: ShowPoster(
                                    imageUrl: item.show.imageUrl,
                                    width: 42,
                                    height: 60,
                                  ),
                                  title: Text(item.show.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.status.label),
                                      RatingStars(
                                        rating: item.personalRating,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Resumo calculado a partir da lista pessoal.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.watchlist});

  final WatchlistController watchlist;

  @override
  Widget build(BuildContext context) {
    final media = watchlist.averageRating;

    return Card(
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${watchlist.count} serie(s) na lista',
              key: const Key('summaryTotal'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(WatchStatus.values
                .map((s) => '${s.label}: ${watchlist.countByStatus(s)}')
                .join('  •  ')),
            Text(media == null
                ? 'Nenhuma serie avaliada ainda'
                : 'Media das minhas notas: ${media.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
  }
}
