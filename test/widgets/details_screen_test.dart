import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serie_track/models/watch_item.dart';
import 'package:serie_track/screens/details_screen.dart';
import 'package:serie_track/state/watchlist_controller.dart';

import '../helpers/fake_show_service.dart';

void main() {
  testWidgets('mostra os detalhes e permite adicionar, mudar status e avaliar',
      (tester) async {
    final watchlist = WatchlistController();
    await tester.pumpWidget(MaterialApp(
      home: DetailsScreen(
        show: fakeShows[0],
        service: FakeShowService(),
        watchlist: watchlist,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('3 temporada(s)'), findsOneWidget);
    expect(find.text('Ator Exemplo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('addToListButton')));
    await tester.pumpAndSettle();

    expect(watchlist.contains(1), isTrue);
    expect(find.byKey(const Key('statusSelector')), findsOneWidget);

    await tester.tap(find.text('Assistindo'));
    await tester.tap(find.byKey(const Key('star_4')));
    await tester.pumpAndSettle();

    expect(watchlist.itemFor(1)!.status, WatchStatus.watching);
    expect(watchlist.itemFor(1)!.personalRating, 4);
    expect(find.text('Nota 4 salva.'), findsOneWidget);
  });

  testWidgets('erro ao carregar detalhes mostra mensagem e botao',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DetailsScreen(
        show: fakeShows[0],
        service: FakeShowService(failDetails: true),
        watchlist: WatchlistController(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Erro no servidor (codigo 500).'), findsOneWidget);
    expect(find.byKey(const Key('retryButton')), findsOneWidget);
  });
}
