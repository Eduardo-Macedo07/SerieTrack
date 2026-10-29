import 'show.dart';

/// Ator do elenco de uma serie.
class CastMember {
  const CastMember({required this.name, required this.character});

  final String name;
  final String character;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? {};
    final character = json['character'] as Map<String, dynamic>? ?? {};

    return CastMember(
      name: person['name'] as String? ?? 'Desconhecido',
      character: character['name'] as String? ?? '',
    );
  }
}

/// Dados completos usados na tela de detalhes:
/// a serie, a quantidade de temporadas e o elenco principal.
class ShowDetails {
  const ShowDetails({
    required this.show,
    required this.seasonCount,
    required this.cast,
  });

  final Show show;
  final int seasonCount;
  final List<CastMember> cast;

  /// JSON de /shows/{id}?embed[]=seasons&embed[]=cast.
  /// As temporadas e o elenco chegam dentro da chave "_embedded".
  factory ShowDetails.fromJson(Map<String, dynamic> json) {
    final embedded = json['_embedded'] as Map<String, dynamic>? ?? {};
    final seasons = embedded['seasons'] as List<dynamic>? ?? [];
    final cast = embedded['cast'] as List<dynamic>? ?? [];

    return ShowDetails(
      show: Show.fromJson(json),
      seasonCount: seasons.length,
      cast: cast
          .map((item) => CastMember.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
