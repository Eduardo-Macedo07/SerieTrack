import '../models/show.dart';

/// Opcoes de ordenacao da lista de resultados.
enum SortOption {
  relevance('Relevancia'),
  ratingDesc('Maior nota'),
  nameAsc('Nome (A-Z)');

  const SortOption(this.label);

  final String label;
}

/// Todos os generos presentes nos resultados, sem repeticao e em ordem.
List<String> availableGenres(List<Show> shows) {
  final generos = <String>{};
  for (final show in shows) {
    generos.addAll(show.genres);
  }
  return generos.toList()..sort();
}

/// Mantem apenas as series do genero escolhido.
/// Se [genre] for null, devolve todas.
List<Show> filterByGenre(List<Show> shows, String? genre) {
  if (genre == null) return List.of(shows);
  return shows.where((show) => show.genres.contains(genre)).toList();
}

/// Devolve uma nova lista ordenada, sem alterar a original.
/// Series sem nota ficam no final quando a ordenacao e por nota.
List<Show> sortShows(List<Show> shows, SortOption option) {
  final copia = List.of(shows);

  switch (option) {
    case SortOption.relevance:
      return copia;
    case SortOption.ratingDesc:
      copia.sort((a, b) => (b.rating ?? -1).compareTo(a.rating ?? -1));
      return copia;
    case SortOption.nameAsc:
      copia
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return copia;
  }
}
