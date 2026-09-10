import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/product_thumb.dart';
import '../../models/category.dart';
import '../../state/cart_provider.dart';
import '../../state/catalog_provider.dart';
import '../../state/app_settings_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final l = context.watch<AppSettingsProvider>().language;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Align(alignment: Alignment.centerLeft, child: Text(l == AppLanguage.kyrgyz ? 'Себет' : 'Корзина', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)))),
          Expanded(
            child: cart.items.isEmpty
                ? Center(child: Text(l == AppLanguage.kyrgyz ? 'Себет бош' : 'Корзина пуста', style: TextStyle(color: scheme.onSurfaceVariant)))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                    children: [
                      for (final item in cart.items)
                        Builder(builder: (context) {
                          final family = context.read<CatalogProvider>().categoryById(item.product.categoryId)?.family ?? CategoryFamily.protection;
                          return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: ProductThumb(product: item.product, family: family, height: 52, borderRadius: BorderRadius.circular(10)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 3),
                                    Text(item.product.sellerName, style: TextStyle(fontSize: 10.5, color: scheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              _QtyStepper(
                                qty: item.quantity,
                                onChanged: (q) => context.read<CartProvider>().updateQuantity(item.product.id, q),
                              ),
                            ],
                          ),
                        );
                        }),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
                        child: Column(
                          children: [
                            _sumRow(context, l == AppLanguage.kyrgyz ? 'Товарлар (${cart.totalCount})' : 'Товары (${cart.totalCount})', cart.subtotal),
                            _sumRow(context, l == AppLanguage.kyrgyz ? 'Жеткирүү' : 'Доставка', CartProvider.deliveryFee),
                            Divider(height: 20, color: Theme.of(context).colorScheme.outlineVariant),
                            _sumRow(context, l == AppLanguage.kyrgyz ? 'Жыйынтык' : 'Итого', cart.total, bold: true),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          if (cart.items.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/checkout'),
                    child: Text(l == AppLanguage.kyrgyz ? 'Буйрутма берүү' : 'Оформить заказ'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sumRow(BuildContext context, String label, double value, {bool bold = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 14 : 12.5, color: bold ? scheme.onSurface : scheme.onSurfaceVariant, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          PriceText(value, size: bold ? 15 : 12.5, color: bold ? scheme.onSurface : scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  const _QtyStepper({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(9)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(context, Icons.remove, () => onChanged(qty - 1)),
          SizedBox(width: 22, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600))),
          _btn(context, Icons.add, () => onChanged(qty + 1)),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, IconData icon, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(width: 24, height: 24, alignment: Alignment.center, color: scheme.surfaceContainerHighest, child: Icon(icon, size: 13)),
    );
  }
}
