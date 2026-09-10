import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../state/seller_order_provider.dart';
import '../../../state/app_settings_provider.dart';
import '../../../data/mock_data.dart';

/// Раздел продавца «Заказы»: простой список покупателей — нажатие на
/// покупателя открывает детали его заказа ([SellerOrderDetailScreen]).
class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerOrders = context.watch<SellerOrderProvider>();
    final drafts = sellerOrders.drafts;
    final language = context.watch<AppSettingsProvider>().language;
    final isKyrgyz = language == AppLanguage.kyrgyz;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKyrgyz ? 'Кардарлардын буйрутмалары' : 'Заказы покупателей'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          if (drafts.isEmpty && sellerOrders.liveOrders.isEmpty && mockSellerOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  isKyrgyz ? 'Азырынча буйрутмалар жок' : 'Пока заказов нет',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),

          // Заказы, созданные покупателями (в этом запуске и демо-данные).
          for (final o in [...sellerOrders.liveOrders, ...mockSellerOrders])
            _CustomerRow(
              name: o.buyerName ?? (isKyrgyz ? 'Кардар' : 'Покупатель'),
              onTap: () => context.push('/seller-orders/${o.id}'),
            ),

          // Заказы, добавленные продавцом вручную со страницы товара.
          for (final d in drafts)
            _CustomerRow(
              name: isKyrgyz ? 'Жаңы буйрутма' : 'Новый заказ',
              icon: Icons.add_task_rounded,
              onTap: () => context.push('/seller-orders/${d.id}'),
            ),
        ],
      ),
    );
  }
}

/// Строка покупателя в списке: круглая иконка-аватар и имя — как в макете.
class _CustomerRow extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;
  const _CustomerRow({required this.name, required this.onTap, this.icon = Icons.person_outline});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: AppColors.cardShadow(dark: dark),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, shape: BoxShape.circle),
                child: Icon(icon, size: 19, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
