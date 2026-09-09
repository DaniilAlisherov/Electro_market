import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/price_text.dart';
import '../../../models/order.dart';
import '../../../state/seller_order_provider.dart';
import '../../../state/app_settings_provider.dart';

/// Экран продавца, который открывается по нажатию на покупателя в разделе
/// «Заказы»: карточка клиента с адресом доставки, список товаров с суммами
/// и переключатель этапа обработки заказа.
class SellerOrderDetailScreen extends StatelessWidget {
  final String orderId;
  const SellerOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final sellerOrders = context.watch<SellerOrderProvider>();
    final isKyrgyz = context.watch<AppSettingsProvider>().language == AppLanguage.kyrgyz;

    final order = sellerOrders.orderById(orderId);
    if (order != null) {
      return _OrderDetailView(
        title: order.buyerName ?? (isKyrgyz ? 'Кардар' : 'Покупатель'),
        address: order.address,
        items: sellerOrders.itemsFor(order),
        total: order.total,
        stage: sellerOrders.stageFor(order.id),
        isKyrgyz: isKyrgyz,
        onStageChanged: (stage) => sellerOrders.setStage(order.id, stage),
      );
    }

    final draft = sellerOrders.draftById(orderId);
    if (draft != null) {
      return _OrderDetailView(
        title: isKyrgyz ? 'Жаңы буйрутма' : 'Новый заказ',
        address: null,
        items: [
          ReceiptItem(
            name: draft.product.name,
            quantity: draft.quantity,
            total: draft.product.price * draft.quantity,
          ),
        ],
        total: draft.product.price * draft.quantity,
        stage: sellerOrders.draftStageFor(draft.id),
        isKyrgyz: isKyrgyz,
        onStageChanged: (stage) => sellerOrders.setDraftStage(draft.id, stage),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(isKyrgyz ? 'Буйрутма табылган жок' : 'Заказ не найден'),
      ),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final String title;
  final String? address;
  final List<ReceiptItem> items;
  final double total;
  final SellerOrderStage stage;
  final bool isKyrgyz;
  final ValueChanged<SellerOrderStage> onStageChanged;

  const _OrderDetailView({
    required this.title,
    required this.address,
    required this.items,
    required this.total,
    required this.stage,
    required this.isKyrgyz,
    required this.onStageChanged,
  });

  static const _stages = [
    SellerOrderStage.processing,
    SellerOrderStage.shipped,
    SellerOrderStage.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(isKyrgyz ? 'Буйрутма' : 'Заказ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // Клиент + адрес доставки.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
              boxShadow: AppColors.cardShadow(dark: dark),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.paper2, shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline, size: 22, color: AppColors.inkSoft),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address ?? (isKyrgyz ? 'Дарек көрсөтүлгөн эмес' : 'Адрес не указан'),
                        style: const TextStyle(fontSize: 12, color: AppColors.inkFaint),
                      ),
                    ],
                  ),
                ),
                if (address != null)
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isKyrgyz ? 'Дарек картада ачылат' : 'Открывает адрес на карте'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.location_on_outlined, color: AppColors.copper),
                    tooltip: isKyrgyz ? 'Картада ачуу' : 'Открыть на карте',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Товары в заказе.
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
              boxShadow: AppColors.cardShadow(dark: dark),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.quantity > 1 ? '${item.name} ×${item.quantity}' : item.name,
                            style: const TextStyle(fontSize: 13, color: AppColors.ink),
                          ),
                        ),
                        PriceText(item.total, size: 13),
                      ],
                    ),
                  ),
                const Divider(height: 1, color: AppColors.line),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      Text(
                        isKyrgyz ? 'Жыйынтыгы:' : 'Итого:',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const Spacer(),
                      PriceText(total, size: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Этап обработки заказа.
          for (final s in _stages) ...[
            _StageOption(
              label: s.label(isKyrgyz),
              selected: stage == s,
              onTap: () => onStageChanged(s),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _StageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _StageOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? scheme.primary : AppColors.line),
          boxShadow: selected
              ? AppColors.floatingShadow(dark: dark, tint: scheme.primary)
              : AppColors.cardShadow(dark: dark),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 18,
              color: selected ? Colors.white : AppColors.inkFaint,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
