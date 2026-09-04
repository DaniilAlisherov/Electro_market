import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

final _priceFormat = NumberFormat.decimalPattern('ru');

class PriceText extends StatelessWidget {
  final double price;
  final double size;
  final Color color;

  const PriceText(this.price, {super.key, this.size = 15, this.color = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_priceFormat.format(price)} сом',
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: size, color: color, fontFamily: 'monospace'),
    );
  }
}
