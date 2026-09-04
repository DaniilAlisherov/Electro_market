import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../models/order.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
              color: AppColors.inkFaint,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(height: 1, color: AppColors.line)),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final OrderStatus status;
  const StatusPill(this.status, {super.key});

  ({Color fg, Color bg}) get _colors {
    switch (status) {
      case OrderStatus.delivered:
        return (fg: AppColors.green, bg: AppColors.greenTint);
      case OrderStatus.transit:
        return (fg: AppColors.blueDark, bg: AppColors.blueTint);
      case OrderStatus.pending:
        return (fg: const Color(0xFF8A5B06), bg: AppColors.yellowTint);
      case OrderStatus.cancelled:
        return (fg: AppColors.red, bg: AppColors.redTint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: c.fg, fontFamily: 'monospace'),
      ),
    );
  }
}

/// То же самое, что [StatusPill], но для этапа обработки заказа продавцом
/// ([SellerOrderStage]) — используется и в «Заказах покупателей» у
/// продавца, и в «Моих заказах» у покупателя, чтобы оба видели один и тот
/// же статус одинаково оформленным.
class StagePill extends StatelessWidget {
  final SellerOrderStage stage;
  final bool isKyrgyz;
  const StagePill(this.stage, {super.key, required this.isKyrgyz});

  ({Color fg, Color bg}) get _colors {
    switch (stage) {
      case SellerOrderStage.searching:
        return (fg: const Color(0xFF8A5B06), bg: AppColors.yellowTint);
      case SellerOrderStage.processing:
        return (fg: AppColors.blueDark, bg: AppColors.blueTint);
      case SellerOrderStage.shipped:
        return (fg: AppColors.graphite, bg: AppColors.graphiteTint);
      case SellerOrderStage.delivered:
        return (fg: AppColors.green, bg: AppColors.greenTint);
      case SellerOrderStage.cancelled:
        return (fg: AppColors.red, bg: AppColors.redTint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        stage.shortLabel(isKyrgyz),
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: c.fg, fontFamily: 'monospace'),
      ),
    );
  }
}

/// Карточка-строка для списков заказов/адресов/выплат.
class InfoListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, size: 19, color: AppColors.inkSoft),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.inkFaint)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
