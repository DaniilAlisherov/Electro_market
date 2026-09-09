import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/price_text.dart';
import '../../../data/mock_data.dart';
import '../../../state/app_settings_provider.dart';
import '../../../state/seller_order_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isKyrgyz = context.watch<AppSettingsProvider>().language == AppLanguage.kyrgyz;
    final sellerOrders = context.watch<SellerOrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          for (final order in [...sellerOrders.liveOrders, ...mockBuyerOrders])
            InfoListTile(
              icon: Icons.receipt_long_outlined,
              title: 'Заказ №${order.id}',
              subtitle: order.summary,
              onTap: () => context.push('/orders/${order.id}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      sellerOrders.hasStage(order.id)
                          ? StagePill(sellerOrders.stageFor(order.id), isKyrgyz: isKyrgyz)
                          : StatusPill(order.status),
                      const SizedBox(height: 4),
                      PriceText(order.total, size: 12),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.chevron_right_rounded, size: 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
