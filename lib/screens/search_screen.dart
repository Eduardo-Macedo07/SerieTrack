import 'package:flutter/material.dart';

import '../models/show.dart';
import '../services/show_service.dart';
import '../state/watchlist_controller.dart';
import '../utils/show_filters.dart';
import '../widgets/request_state_views.dart';
import '../widgets/show_card.dart';
import 'details_screen.dart';

/// Estados possiveis de uma requisicao a API.
enum RequestStatus { idle, loading, success, error }

/// Tela de pesquisa: busca series na API, filtra por genero e ordena.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.service,
    required this.watchlist,
  });

  final ShowService service;
  final WatchlistController watchlist;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();

  RequestStatus _status = RequestStatus.idle;
  List<Show> _results = [];
  String _errorMessage = '';
  String _lastQuery = '';

  String? _selectedGenre;
  SortOption _sort = SortOption.relevance;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  /// Chama a API de forma assincrona e atualiza o estado da tela
  /// em cada etapa: carregando -> sucesso ou erro.
  Future<void> _search() async {
    final query = _queryController.text.trim();
    FocusScope.of(context).unfocus();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome de uma serie.')),
      );
      return;
    }

    setState(() {
      _status = RequestStatus.loading;
      _lastQuery = query;
      _selectedGenre = null;
    });

    try {
      final shows = await widget.service.searchShows(query);
      if (!mounted) return;
      setState(() {
        _results = shows;
        _status = RequestStatus.success;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _status = RequestStatus.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Ocorreu um erro inesperado.';
        _status = RequestStatus.error;
      });
    }
  }

  void _openDetails(Show show) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetailsScreen(
          show: show,
          service: widget.service,
          watchlist: widget.watchlist,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar series')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('searchField'),
                      controller: _queryController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        labelText: 'Nome da serie',
                        hintText: 'Ex.: Friends, Dark, The Office',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('searchButton'),
                    onPressed:
                        _status == RequestStatus.loading ? null : _search,
                    child: const Text('Buscar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case RequestStatus.idle:
        return const EmptyView(
          icon: Icons.live_tv,
          message: 'Pesquise uma serie para comecar.\n'
              'Os dados vem da API publica do TVMaze.',
        );
      case RequestStatus.loading:
        return const LoadingView(message: 'Buscando series...');
      case RequestStatus.error:
        return ErrorView(message: _errorMessage, onRetry: _search);
      case RequestStatus.success:
        if (_results.isEmpty) {
          return EmptyView(
            icon: Icons.search_off,
            message: 'Nenhuma serie encontrada para "$_lastQuery".',
          );
        }
        return _buildResults();
    }
  }

  Widget _buildResults() {
    final genres = availableGenres(_results);
    final visible = sortShows(filterByGenre(_results, _selectedGenre), _sort);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: const Text('Todos'),
                  selected: _selectedGenre == null,
                  onSelected: (_) => setState(() => _selectedGenre = null),
                ),
              ),
              ...genres.map(
                (genre) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    key: Key('genre_$genre'),
                    label: Text(genre),
                    selected: _selectedGenre == genre,
                    onSelected: (_) => setState(() => _selectedGenre = genre),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${visible.length} resultado(s)',
                key: const Key('resultCount'),
              ),
            ),
            const Text('Ordenar: '),
            DropdownButton<SortOption>(
              key: const Key('sortDropdown'),
              value: _sort,
              onChanged: (option) {
                if (option != null) setState(() => _sort = option);
              },
              items: SortOption.values
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option.label),
                      ))
                  .toList(),
            ),
          ],
        ),
        Expanded(
          // Escuta a lista pessoal para atualizar o icone "na lista".
          child: ListenableBuilder(
            listenable: widget.watchlist,
            builder: (context, _) => ListView.builder(
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final show = visible[index];
                return ShowCard(
                  key: Key('showCard_${show.id}'),
                  show: show,
                  inWatchlist: widget.watchlist.contains(show.id),
                  onTap: () => _openDetails(show),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
