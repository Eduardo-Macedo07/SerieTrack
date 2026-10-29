import 'package:flutter/foundation.dart';

import '../models/show.dart';
import '../models/watch_item.dart';

/// Guarda a lista pessoal de series (estado compartilhado entre telas).
///
/// Estende ChangeNotifier: sempre que algo muda, notifyListeners() avisa as
/// telas que estao escutando (via ListenableBuilder) para se redesenharem.
class WatchlistController extends ChangeNotifier {
  final Map<int, WatchItem> _items = {};

  /// Itens na ordem em que foram adicionados.
  List<WatchItem> get items => List.unmodifiable(_items.values);

  int get count => _items.length;

  bool contains(int showId) => _items.containsKey(showId);

  WatchItem? itemFor(int showId) => _items[showId];

  void add(Show show, {WatchStatus status = WatchStatus.wantToWatch}) {
    _items[show.id] = WatchItem(show: show, status: status);
    notifyListeners();
  }

  void remove(int showId) {
    if (_items.remove(showId) != null) notifyListeners();
  }

  /// Usado pelo "Desfazer" do SnackBar depois de remover um item.
  void restore(WatchItem item) {
    _items[item.show.id] = item;
    notifyListeners();
  }

  void updateStatus(int showId, WatchStatus status) {
    final item = _items[showId];
    if (item == null) return;
    _items[showId] = item.copyWith(status: status);
    notifyListeners();
  }

  /// Define a nota pessoal (1 a 5). Valores fora do intervalo sao rejeitados.
  void setRating(int showId, int rating) {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('A nota deve estar entre 1 e 5.');
    }
    final item = _items[showId];
    if (item == null) return;
    _items[showId] = item.copyWith(personalRating: rating);
    notifyListeners();
  }

  /// Itens filtrados por status. Se [status] for null, devolve todos.
  List<WatchItem> byStatus(WatchStatus? status) {
    if (status == null) return items;
    return _items.values.where((item) => item.status == status).toList();
  }

  int countByStatus(WatchStatus status) => byStatus(status).length;

  /// Media das notas pessoais (ignora series sem nota). Null se nao houver.
  double? get averageRating {
    final notas = _items.values
        .map((item) => item.personalRating)
        .whereType<int>()
        .toList();
    if (notas.isEmpty) return null;
    return notas.reduce((a, b) => a + b) / notas.length;
  }
}
