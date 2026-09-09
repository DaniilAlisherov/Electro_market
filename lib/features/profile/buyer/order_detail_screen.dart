import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/price_text.dart';
import '../../../models/order.dart';
import '../../../state/app_settings_provider.dart';
import '../../../state/seller_order_provider.dart';

class BuyerOrderDetailScreen extends StatelessWidget {
  final String orderId;
  const BuyerOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<SellerOrderProvider>();
    final isKyrgyz = context.watch<AppSettingsProvider>().language == AppLanguage.kyrgyz;
    final order = orders.orderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isKyrgyz ? 'Буйрутма' : 'Заказ')),
        body: Center(child: Text(isKyrgyz ? 'Буйрутма табылган жок' : 'Заказ не найден')),
      );
    }

    return _BuyerOrderDetailView(order: order, isKyrgyz: isKyrgyz);
  }
}

class _BuyerOrderDetailView extends StatelessWidget {
  final BuyerOrder order;
  final bool isKyrgyz;

  const _BuyerOrderDetailView({required this.order, required this.isKyrgyz});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellerOrderProvider>();
    final stage = provider.stageFor(order.id);
    final items = provider.itemsFor(order);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final delivery = provider.receiptFor(order.id)?.delivery ?? 0;
    final subtotal = provider.receiptFor(order.id)?.subtotal ?? (order.total - delivery).clamp(0, double.infinity).toDouble();

    return Scaffold(
      appBar: AppBar(title: Text(isKyrgyz ? 'Толук маалымат' : 'Подробности заказа')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          _StatusCard(stage: stage, status: order.status, isKyrgyz: isKyrgyz, dark: dark),
          const SizedBox(height: 14),
          _SectionCard(
            dark: dark,
            title: isKyrgyz ? 'Товарлар' : 'Товары в заказе',
            icon: Icons.shopping_bag_outlined,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _ItemRow(item: items[i]),
                  if (i != items.length - 1) const Divider(height: 1, color: AppColors.line),
                ],
                const Divider(height: 1, color: AppColors.line),
                _SummaryRow(label: isKyrgyz ? 'Товарлар:' : 'Товары:', value: subtotal),
                _SummaryRow(label: isKyrgyz ? 'Жеткирүү:' : 'Доставка:', value: delivery),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(isKyrgyz ? 'Жыйынтыгы:' : 'Итого:', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const Spacer(),
                    PriceText(order.total, size: 17),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            dark: dark,
            title: isKyrgyz ? 'Жеткирүү' : 'Доставка',
            icon: Icons.location_on_outlined,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    order.address ?? (isKyrgyz ? 'Дарек көрсөтүлгөн эмес' : 'Адрес не указан'),
                    style: const TextStyle(fontSize: 13, height: 1.35, color: AppColors.ink),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.local_shipping_outlined, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            dark: dark,
            title: isKyrgyz ? 'Сатуучу' : 'Продавец',
            icon: Icons.storefront_outlined,
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.storefront_outlined, color: AppColors.inkSoft),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isKyrgyz ? 'Продавец' : 'Продавец', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      const SizedBox(height: 3),
                      Text(isKyrgyz ? 'Маалымат заказдын ичинде' : 'Информация доступна в заказе', style: const TextStyle(fontSize: 11, color: AppColors.inkFaint)),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/chats/seller-1'),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: Text(isKyrgyz ? 'Чат' : 'Чат'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            dark: dark,
            title: isKyrgyz ? 'Маалымат' : 'Информация',
            icon: Icons.info_outline,
            child: Column(
              children: [
                _InfoRow(label: isKyrgyz ? 'Номер' : 'Номер заказа', value: '#${order.id}'),
                const SizedBox(height: 9),
                _InfoRow(label: isKyrgyz ? 'Күнү' : 'Дата заказа', value: _date(order.createdAt)),
                const SizedBox(height: 9),
                _InfoRow(label: isKyrgyz ? 'Позициялар' : 'Количество позиций', value: '${order.itemCount}'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (stage != SellerOrderStage.cancelled)
            FilledButton.icon(
              onPressed: () => _showTracking(context, stage),
              icon: const Icon(Icons.route_outlined),
              label: Text(isKyrgyz ? 'Заказды көзөмөлдөө' : 'Отследить заказ'),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isKyrgyz ? 'Жардам бөлүмү ачылат' : 'Раздел помощи скоро будет доступен'))),
            icon: const Icon(Icons.support_agent_outlined),
            label: Text(isKyrgyz ? 'Жардам керек' : 'Нужна помощь'),
          ),
        ],
      ),
    );
  }

  static String _date(DateTime? value) {
    if (value == null) return '—';
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
  }

  void _showTracking(BuildContext context, SellerOrderStage stage) {
    final steps = [
      SellerOrderStage.processing,
      SellerOrderStage.shipped,
      SellerOrderStage.delivered,
    ];
    final current = steps.indexOf(stage);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isKyrgyz ? 'Статус заказ' : 'Статус заказа', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              for (var i = 0; i < steps.length; i++)
                _TrackingStep(label: steps[i].label(isKyrgyz), active: i <= current, last: i == steps.length - 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final SellerOrderStage stage;
  final OrderStatus status;
  final bool isKyrgyz;
  final bool dark;
  const _StatusCard({required this.stage, required this.status, required this.isKyrgyz, required this.dark});

  @override
  Widget build(BuildContext context) {
    final label = stage.label(isKyrgyz);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.floatingShadow(dark: dark, tint: Theme.of(context).colorScheme.primary),
      ),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle), child: const Icon(Icons.local_shipping_outlined, color: Colors.white)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isKyrgyz ? 'Статус заказ' : 'Статус заказа', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .75))),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
          ])),
          Text('#${status == OrderStatus.cancelled ? '!' : ''}${stage == SellerOrderStage.cancelled ? 'X' : ''}', style: TextStyle(color: Colors.white.withValues(alpha: .55), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final bool dark;
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.dark, required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line), boxShadow: AppColors.cardShadow(dark: dark)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink))]),
          const SizedBox(height: 13),
          child,
        ]),
      );
}

class _ItemRow extends StatelessWidget {
  final ReceiptItem item;
  const _ItemRow({required this.item});

  String? _imageFor(String name) {
    final value = name.toLowerCase();
    if (value.contains('c16') || value.contains('автомат c16')) return 'assets/product/c16.jpg';
    if (value.contains('c25') || value.contains('автомат c25')) return 'assets/product/c25.jpg';
    if (value.contains('узо')) return 'assets/product/yzo25a.jpg';
    if (value.contains('кабель')) return 'assets/product/kabel3x2.jpg';
    if (value.contains('din')) return 'assets/product/din-35.jpg';
    if (value.contains('розет')) return 'assets/product/socket16a.jpg';
    if (value.contains('свет') || value.contains('led')) return 'assets/product/light-led-18.jpg';
    if (value.contains('реле')) return 'assets/product/rele24b.jpg';
    if (value.contains('выключ')) return 'assets/product/switch-1g.jpg';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _imageFor(item.name);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.paper2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: image != null
                  ? Image.asset(image, fit: BoxFit.contain)
                  : const Icon(Icons.inventory_2_outlined, color: AppColors.inkSoft),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              item.quantity > 1 ? '${item.name} ×${item.quantity}' : item.name,
              style: const TextStyle(fontSize: 13, color: AppColors.ink),
            ),
          ),
          PriceText(item.total, size: 13),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Text(label, style: const TextStyle(fontSize: 12, color: AppColors.inkFaint)), const Spacer(), PriceText(value, size: 12)]));
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [Text(label, style: const TextStyle(fontSize: 12, color: AppColors.inkFaint)), const Spacer(), Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)))]);
}

class _TrackingStep extends StatelessWidget {
  final String label;
  final bool active;
  final bool last;
  const _TrackingStep({required this.label, required this.active, required this.last});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [Container(width: 13, height: 13, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? Theme.of(context).colorScheme.primary : AppColors.line)), if (!last) Container(width: 2, height: 29, color: active ? Theme.of(context).colorScheme.primary : AppColors.line)]),
        const SizedBox(width: 12),
        Padding(padding: const EdgeInsets.only(top: 0), child: Text(label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? AppColors.ink : AppColors.inkFaint))),
      ]);
}
