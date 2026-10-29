import 'package:flutter/material.dart';

/// Cinco estrelas para a nota pessoal.
/// Se [onChanged] for informado, o usuario pode tocar para avaliar.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 28,
  });

  final int? rating;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final valor = index + 1;
        final preenchida = rating != null && valor <= rating!;
        final estrela = Icon(
          preenchida ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );

        if (onChanged == null) return estrela;

        return IconButton(
          key: Key('star_$valor'),
          tooltip: '$valor estrela${valor > 1 ? 's' : ''}',
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged!(valor),
          icon: estrela,
        );
      }),
    );
  }
}
