import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serie_track/app.dart';
import 'package:serie_track/state/watchlist_controller.dart';

import '../helpers/fake_show_service.dart';

Future<void> pumpApp(WidgetTester tester, FakeShowService service) {
  return tester.pumpWidget(
    SerieTrackApp(service: service, watchlist: WatchlistController()),
  );
}

Future<void> search(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('searchField')), text);
  await tester.tap(find.byKey(const Key('searchButton')));
}

void main() {
  testWidgets('mostra o carregamento e depois os resultados', (tester) async {
    final service = FakeShowService()..searchGate = Completer<void>();
    await pumpApp(tester, service);

    expect(
        find.text('Pesquise uma serie para comecar.\n'
            'Os dados vem da API publica do TVMaze.'),
        findsOneWidget);

    await search(tester, 'dark');
    await tester.pump();

    // Enquanto a "API" nao responde, aparece o indicador de carregamento.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Buscando series...'), findsOneWidget);

    service.searchGate!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('1 resultado(s)'), findsOneWidget);
  });

  testWidgets('em caso de erro mostra a mensagem e permite tentar de novo',
      (tester) async {
    final service = FakeShowService(failSearch: true);
    await pumpApp(tester, service);

    await search(tester, 'dark');
    await tester.pumpAndSettle();

    expect(find.text('Sem conexao com a internet. Verifique sua rede.'),
        findsOneWidget);
    expect(find.byKey(const Key('retryButton')), findsOneWidget);

    service.failSearch = false;
    await tester.tap(find.byKey(const Key('retryButton')));
    await tester.pumpAndSettle();

    expect(find.text('Dark'), findsOneWidget);
    expect(service.searchCalls, 2);
  });

  testWidgets('pesquisa sem resultados mostra mensagem de lista vazia',
      (tester) async {
    await pumpApp(tester, FakeShowService());

    await search(tester, 'xyz');
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma serie encontrada para "xyz".'), findsOneWidget);
  });

  testWidgets('filtro de genero atualiza a lista exibida', (tester) async {
    await pumpApp(tester, FakeShowService());

    // "o" aparece em "The Office" e "Brooklyn Nine-Nine".
    await search(tester, 'o');
    await tester.pumpAndSettle();
    expect(find.text('2 resultado(s)'), findsOneWidget);
    expect(find.text('The Office'), findsOneWidget);

    await tester.tap(find.byKey(const Key('genre_Crime')));
    await tester.pumpAndSettle();

    expect(find.text('1 resultado(s)'), findsOneWidget);
    expect(find.text('Brooklyn Nine-Nine'), findsOneWidget);
    expect(find.text('The Office'), findsNothing);
  });
}
