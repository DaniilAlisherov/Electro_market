import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/cart_provider.dart';
import '../state/user_provider.dart';
import '../state/app_settings_provider.dart';
import '../state/seller_order_provider.dart';
import '../core/theme/app_colors.dart';
import '../models/order.dart';
import '../models/payment_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _method = 'online';

  bool _cardIsValid(PaymentCard? card) {
    if (card == null) return false;
    final now = DateTime.now();
    if (card.expiryMonth < 1 || card.expiryMonth > 12) return false;
    return card.expiryYear > now.year ||
        (card.expiryYear == now.year && card.expiryMonth >= now.month);
  }

  void _placeOrder() {
    final l = context.read<AppSettingsProvider>().language;
    final cart = context.read<CartProvider>();
    final user = context.read<UserProvider>();
    final sellerOrders = context.read<SellerOrderProvider>();
    final card = user.defaultCard;

    if (_method == 'online' && !_cardIsValid(card)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l == AppLanguage.kyrgyz
              ? 'Карта туура эмес же мөөнөтү бүткөн.'
              : 'Карта введена неверно или срок её действия истёк.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (user.address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l == AppLanguage.kyrgyz
              ? 'Алгач Манас шаарындагы жеткирүү дарегин кошуңуз.'
              : 'Сначала добавьте адрес доставки в городе Манас.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final summary = cart.items
        .map((e) => '${e.product.name} ×${e.quantity}')
        .join(', ');

    final orderId = sellerOrders.createBuyerOrder(
      summary: summary,
      total: cart.total,
      buyerName: user.name,
      buyerPhone: user.phone,
      itemCount: cart.items.fold<int>(0, (sum, item) => sum + item.quantity),
      receiptItems: [
        for (final item in cart.items)
          ReceiptItem(
            name: item.product.name,
            quantity: item.quantity,
            total: item.total,
          ),
      ],
      delivery: CartProvider.deliveryFee,
      address: '${user.address!.label}: ${user.address!.details}',
    );

    cart.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline_rounded, size: 42),
        title: Text(l == AppLanguage.kyrgyz ? 'Буйрутма кабыл алынды' : 'Заказ принят'),
        content: Text(
          l == AppLanguage.kyrgyz
              ? '№$orderId буйрутма сатуучуга жөнөтүлдү.'
              : 'Заказ №$orderId отправлен продавцу. Он уже появился в кабинете продавца.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/catalog');
            },
            child: Text(l == AppLanguage.kyrgyz ? 'Жакшы' : 'Готово'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppSettingsProvider>().language;
    final cart = context.watch<CartProvider>();
    final user = context.watch<UserProvider>();

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.checkout(l))),
        body: Center(child: Text(l == AppLanguage.kyrgyz ? 'Себет бош' : 'Корзина пуста')),
      );
    }

    final card = user.defaultCard;
    final cardValid = _cardIsValid(card);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.checkout(l))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          _sectionTitle(l == AppLanguage.kyrgyz ? 'ЖЕТКИРҮҮ' : 'ДОСТАВКА'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.address == null
                        ? (l == AppLanguage.kyrgyz ? 'Дарек кошулган эмес' : 'Адрес не добавлен')
                        : '${user.address!.label}: ${user.address!.details}',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
                IconButton(onPressed: () => context.push('/addresses/edit'), icon: const Icon(Icons.edit_outlined, size: 18)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle(l == AppLanguage.kyrgyz ? 'ТӨЛӨМ ЫКМАСЫ' : 'СПОСОБ ОПЛАТЫ'),
          RadioListTile(
            value: 'online',
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v!),
            title: Text(l == AppLanguage.kyrgyz ? 'Банк картасы' : 'Банковская карта'),
            subtitle: Text(card == null
                ? (l == AppLanguage.kyrgyz ? 'Карта кошуңуз' : 'Добавьте карту')
                : '•••• ${card.last4}${cardValid ? ' · ${l == AppLanguage.kyrgyz ? 'Жарактуу' : 'Действительна'}' : ' · ${l == AppLanguage.kyrgyz ? 'Текшерүү керек' : 'Нужно проверить'}'}'),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile(
            value: 'cash',
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v!),
            title: Text(l == AppLanguage.kyrgyz ? 'Накталай төлөө' : 'Оплата при получении'),
            contentPadding: EdgeInsets.zero,
          ),
          if (_method == 'online' && card == null)
            OutlinedButton.icon(
              onPressed: () => context.push('/payments'),
              icon: const Icon(Icons.add_card_rounded),
              label: Text(l == AppLanguage.kyrgyz ? 'Карта кошуу' : 'Добавить карту'),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark),
            ),
            child: Column(children: [
              _row(l == AppLanguage.kyrgyz ? 'Товарлар' : 'Товары', cart.subtotal),
              _row(l == AppLanguage.kyrgyz ? 'Жеткирүү' : 'Доставка', CartProvider.deliveryFee),
              const Divider(height: 22),
              _row(l == AppLanguage.kyrgyz ? 'Баары' : 'Итого', cart.total, bold: true),
            ]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _method == 'online' && !cardValid ? null : _placeOrder,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(l == AppLanguage.kyrgyz ? 'Ырастоо жана заказ берүү' : 'Подтвердить и оформить заказ'),
          ),
          const SizedBox(height: 9),
          Text(
            l == AppLanguage.kyrgyz
                ? 'Демо-режим: карта жергиликтүү текшерилет, реалдуу акча алынбайт.'
                : 'Демо-режим: карта проверяется локально, реальные деньги не списываются.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(fontSize: 10.5, letterSpacing: .8, color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );

  Widget _row(String label, double value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: bold ? 13.5 : 12.5, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      Text('${value.toStringAsFixed(0)} сом', style: TextStyle(fontSize: bold ? 15 : 12.5, fontWeight: FontWeight.w700)),
    ]),
  );
}
