import 'package:flutter_test/flutter_test.dart';
import 'package:serie_track/models/watch_item.dart';
import 'package:serie_track/state/watchlist_controller.dart';

import '../helpers/fake_show_service.dart';

void main() {
  late WatchlistController controller;

  setUp(() => controller = WatchlistController());

  test('adicionar e remover series atualiza a lista e notifica', () {
    var notificacoes = 0;
    controller.addListener(() => notificacoes++);

    controller.add(fakeShows[0]);
    controller.add(fakeShows[1], status: WatchStatus.watching);

    expect(controller.count, 2);
    expect(controller.contains(1), isTrue);
    expect(controller.itemFor(2)!.status, WatchStatus.watching);

    controller.remove(1);

    expect(controller.contains(1), isFalse);
    expect(notificacoes, 3);
  });

  test('filtra por status e calcula a media das notas pessoais', () {
    controller.add(fakeShows[0]);
    controller.add(fakeShows[1]);
    controller.add(fakeShows[2]);
    controller.updateStatus(1, WatchStatus.completed);
    controller.setRating(1, 5);
    controller.setRating(2, 2);

    expect(controller.byStatus(WatchStatus.completed).single.show.name, 'Dark');
    expect(controller.countByStatus(WatchStatus.wantToWatch), 2);
    expect(controller.byStatus(null).length, 3);
    expect(controller.averageRating, 3.5);
  });

  test('rejeita nota fora do intervalo de 1 a 5', () {
    controller.add(fakeShows[0]);

    expect(() => controller.setRating(1, 0), throwsArgumentError);
    expect(() => controller.setRating(1, 6), throwsArgumentError);
    expect(controller.averageRating, isNull);
  });
}
