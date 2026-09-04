import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Оценка молниями вместо звёзд — фирменная деталь ЭлектроМаркета
/// (электротехника → молния). Используется и для отображения готовой
/// оценки, и как интерактивный выбор оценки от покупателя.
class BoltRating extends StatelessWidget {
  final double rating; // 0..5, допускаются дробные значения для среднего
  final double size;
  const BoltRating({super.key, required this.rating, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i && rating < i + 1;
        return Icon(
          half ? Icons.bolt_outlined : Icons.bolt,
          size: size,
          color: filled || half ? AppColors.yellow : AppColors.line,
        );
      }),
    );
  }
}

/// Интерактивный выбор оценки от 0 до 5 молниями — используется в форме
/// отзыва покупателя на странице товара.
class BoltRatingInput extends StatelessWidget {
  final int value; // 0..5
  final ValueChanged<int> onChanged;
  final double size;
  const BoltRatingInput({super.key, required this.value, required this.onChanged, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = value >= i + 1;
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.bolt,
              size: size,
              color: filled ? AppColors.yellow : AppColors.line,
            ),
          ),
        );
      }),
    );
  }
}
