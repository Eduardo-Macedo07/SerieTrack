import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serie_track/app.dart';
import 'package:serie_track/state/watchlist_controller.dart';

import '../test/helpers/fake_show_service.dart';

/// Fluxo completo: abrir app -> pesquisar -> abrir detalhes ->
/// adicionar a lista e avaliar -> conferir na aba "Minha lista".
///
/// Usa o servico falso para que o teste nao dependa da API estar no ar.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pesquisar, adicionar a lista, avaliar e conferir',
      (tester) async {
    await tester.pumpWidget(SerieTrackApp(
      service: FakeShowService(),
      watchlist: WatchlistController(),
    ));

    // 1. Pesquisar
    await tester.enterText(find.byKey(const Key('searchField')), 'office');
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();
    expect(find.text('The Office'), findsOneWidget);

    // 2. Abrir detalhes
    await tester.tap(find.byKey(const Key('showCard_2')));
    await tester.pumpAndSettle();
    expect(find.text('Sinopse'), findsOneWidget);

    // 3. Executar acoes: adicionar, marcar como concluida e dar nota 5
    await tester.tap(find.byKey(const Key('addToListButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluida'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('star_5')));
    await tester.pumpAndSettle();

    // 4. Voltar e verificar o resultado na pesquisa e na lista pessoal
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Na minha lista'), findsOneWidget);

    await tester.tap(find.byKey(const Key('watchlistTab')));
    await tester.pumpAndSettle();

    expect(find.text('1 serie(s) na lista'), findsOneWidget);
    expect(find.text('Media das minhas notas: 5.0'), findsOneWidget);
    expect(find.byKey(const Key('watchItem_2')), findsOneWidget);
    expect(find.text('Concluida'), findsWidgets);
  });
}
