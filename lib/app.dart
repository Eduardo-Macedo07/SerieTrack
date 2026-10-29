import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/show_service.dart';
import 'state/watchlist_controller.dart';

/// Raiz do aplicativo. Recebe o servico e o controlador por parametro
/// (injecao de dependencia): no app real vem a API do TVMaze; nos testes,
/// um servico falso com dados simulados.
class SerieTrackApp extends StatelessWidget {
  const SerieTrackApp({
    super.key,
    required this.service,
    required this.watchlist,
  });

  final ShowService service;
  final WatchlistController watchlist;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SerieTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: HomeScreen(service: service, watchlist: watchlist),
    );
  }
}
