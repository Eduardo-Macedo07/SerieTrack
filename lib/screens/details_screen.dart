import 'package:flutter/material.dart';

import '../models/show.dart';
import '../models/show_details.dart';
import '../models/watch_item.dart';
import '../services/show_service.dart';
import '../state/watchlist_controller.dart';
import '../widgets/rating_stars.dart';
import '../widgets/request_state_views.dart';
import '../widgets/show_poster.dart';

/// Detalhes de uma serie (dados completos buscados na API) e acoes da
/// lista pessoal: adicionar, mudar status, avaliar e remover.
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.show,
    required this.service,
    required this.watchlist,
  });

  /// Dados basicos ja conhecidos (vindos da pesquisa ou da lista).
  final Show show;
  final ShowService service;
  final WatchlistController watchlist;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  ShowDetails? _details;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final details = await widget.service.fetchDetails(widget.show.id);
      if (!mounted) return;
      setState(() {
        _details = details;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Nao foi possivel carregar os detalhes.';
        _loading = false;
      });
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.show.name)),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingView(message: 'Carregando detalhes...');
    }
    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _loadDetails);
    }

    final details = _details!;
    final show = details.show;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShowPoster(imageUrl: show.imageUrl, width: 110, height: 155),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(show.name, style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _InfoLine(
                    icon: Icons.star,
                    text: show.rating != null
                        ? 'Nota TVMaze: ${show.rating!.toStringAsFixed(1)}'
                        : 'Sem nota no TVMaze',
                  ),
                  if (show.year != null)
                    _InfoLine(icon: Icons.event, text: 'Estreia: ${show.year}'),
                  _InfoLine(
                    icon: Icons.layers,
                    text: '${details.seasonCount} temporada(s)',
                  ),
                  if (show.network != null)
                    _InfoLine(icon: Icons.tv, text: show.network!),
                  if (show.status != null)
                    _InfoLine(icon: Icons.info_outline, text: show.status!),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: show.genres
              .map((genre) => Chip(
                    label: Text(genre),
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        _buildWatchlistSection(show),
        const SizedBox(height: 16),
        Text('Sinopse', style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(show.summary.isEmpty ? 'Sinopse indisponivel.' : show.summary),
        if (details.cast.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Elenco principal', style: textTheme.titleMedium),
          ...details.cast.take(6).map(
                (member) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(member.name),
                  subtitle:
                      member.character.isEmpty ? null : Text(member.character),
                ),
              ),
        ],
      ],
    );
  }

  /// Parte que depende da lista pessoal. O ListenableBuilder redesenha
  /// somente esta area quando o WatchlistController notifica mudancas.
  Widget _buildWatchlistSection(Show show) {
    return ListenableBuilder(
      listenable: widget.watchlist,
      builder: (context, _) {
        final item = widget.watchlist.itemFor(show.id);

        if (item == null) {
          return FilledButton.icon(
            key: const Key('addToListButton'),
            onPressed: () {
              widget.watchlist.add(show);
              _showMessage('"${show.name}" adicionada a sua lista.');
            },
            icon: const Icon(Icons.bookmark_add),
            label: const Text('Adicionar a minha lista'),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Na minha lista',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<WatchStatus>(
                  key: const Key('statusSelector'),
                  showSelectedIcon: false,
                  segments: WatchStatus.values
                      .map((status) => ButtonSegment(
                            value: status,
                            label: Text(status.label),
                          ))
                      .toList(),
                  selected: {item.status},
                  onSelectionChanged: (selecao) {
                    widget.watchlist.updateStatus(show.id, selecao.first);
                  },
                ),
                const SizedBox(height: 8),
                const Text('Minha nota:'),
                RatingStars(
                  rating: item.personalRating,
                  onChanged: (nota) {
                    widget.watchlist.setRating(show.id, nota);
                    _showMessage('Nota $nota salva.');
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const Key('removeButton'),
                    onPressed: () {
                      widget.watchlist.remove(show.id);
                      _showMessage('"${show.name}" removida da lista.');
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remover da lista'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
