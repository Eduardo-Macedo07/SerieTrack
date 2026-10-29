import 'package:flutter/material.dart';

import '../services/show_service.dart';
import '../state/watchlist_controller.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';

/// Tela principal com navegacao inferior entre Pesquisa e Minha lista.
/// O IndexedStack mantem o estado de cada aba ao trocar entre elas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.service,
    required this.watchlist,
  });

  final ShowService service;
  final WatchlistController watchlist;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          SearchScreen(service: widget.service, watchlist: widget.watchlist),
          WatchlistScreen(service: widget.service, watchlist: widget.watchlist),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: widget.watchlist,
        builder: (context, _) => NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Pesquisar',
            ),
            NavigationDestination(
              key: const Key('watchlistTab'),
              icon: Badge(
                isLabelVisible: widget.watchlist.count > 0,
                label: Text('${widget.watchlist.count}'),
                child: const Icon(Icons.bookmark_border),
              ),
              selectedIcon: const Icon(Icons.bookmark),
              label: 'Minha lista',
            ),
          ],
        ),
      ),
    );
  }
}
