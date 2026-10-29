import 'show.dart';

/// Situacao da serie na lista pessoal do usuario.
enum WatchStatus {
  wantToWatch('Quero ver'),
  watching('Assistindo'),
  completed('Concluida');

  const WatchStatus(this.label);

  final String label;
}

/// Uma serie salva na lista pessoal, com status e nota do usuario.
class WatchItem {
  const WatchItem({
    required this.show,
    required this.status,
    this.personalRating,
  });

  final Show show;
  final WatchStatus status;

  /// Nota pessoal de 1 a 5 estrelas (null = ainda nao avaliada).
  final int? personalRating;

  WatchItem copyWith({WatchStatus? status, int? personalRating}) {
    return WatchItem(
      show: show,
      status: status ?? this.status,
      personalRating: personalRating ?? this.personalRating,
    );
  }
}
