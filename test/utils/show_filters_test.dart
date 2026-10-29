import 'package:flutter_test/flutter_test.dart';
import 'package:serie_track/utils/show_filters.dart';

import '../helpers/fake_show_service.dart';

void main() {
  test('availableGenres lista os generos sem repeticao e em ordem', () {
    expect(
      availableGenres(fakeShows),
      ['Comedy', 'Crime', 'Drama', 'Science-Fiction'],
    );
  });

  test('filterByGenre mantem apenas as series do genero escolhido', () {
    final comedias = filterByGenre(fakeShows, 'Comedy');

    expect(comedias.map((s) => s.name), ['The Office', 'Brooklyn Nine-Nine']);
    expect(filterByGenre(fakeShows, null).length, 3);
  });

  test('sortShows por nota coloca a maior primeiro e sem nota no final', () {
    final ordenadas = sortShows(fakeShows, SortOption.ratingDesc);

    expect(
      ordenadas.map((s) => s.name),
      ['Dark', 'The Office', 'Brooklyn Nine-Nine'],
    );
  });

  test('sortShows por nome ordena de A a Z sem alterar a lista original', () {
    final original = List.of(fakeShows);
    final ordenadas = sortShows(fakeShows, SortOption.nameAsc);

    expect(
      ordenadas.map((s) => s.name),
      ['Brooklyn Nine-Nine', 'Dark', 'The Office'],
    );
    expect(fakeShows, original);
  });
}
