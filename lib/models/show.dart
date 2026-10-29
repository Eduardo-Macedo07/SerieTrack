import '../utils/html_utils.dart';

/// Representa uma serie retornada pela API do TVMaze.
class Show {
  const Show({
    required this.id,
    required this.name,
    required this.genres,
    this.rating,
    this.imageUrl,
    this.summary = '',
    this.language,
    this.status,
    this.premiered,
    this.network,
  });

  final int id;
  final String name;
  final List<String> genres;

  /// Nota media do TVMaze (0 a 10). Pode nao existir.
  final double? rating;
  final String? imageUrl;
  final String summary;
  final String? language;
  final String? status;
  final String? premiered;
  final String? network;

  /// Ano de estreia extraido de "2005-03-24".
  String? get year => premiered != null && premiered!.length >= 4
      ? premiered!.substring(0, 4)
      : null;

  /// Cria um Show a partir do JSON de uma serie do TVMaze.
  ///
  /// Varios campos podem vir nulos na API, por isso cada um e tratado.
  factory Show.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final rating = json['rating'] as Map<String, dynamic>?;
    final network = json['network'] as Map<String, dynamic>?;
    final webChannel = json['webChannel'] as Map<String, dynamic>?;

    return Show(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Sem titulo',
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map((genero) => genero as String)
          .toList(),
      rating: (rating?['average'] as num?)?.toDouble(),
      imageUrl: image?['medium'] as String?,
      summary: stripHtml(json['summary'] as String?),
      language: json['language'] as String?,
      status: json['status'] as String?,
      premiered: json['premiered'] as String?,
      network: (network?['name'] ?? webChannel?['name']) as String?,
    );
  }
}
