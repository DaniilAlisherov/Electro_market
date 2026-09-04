import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/user_role.dart';
import '../../state/user_provider.dart';
import '../../state/seller_order_provider.dart';
import '../../state/app_settings_provider.dart';
import '../../state/catalog_provider.dart';
import '../theme/app_colors.dart';
import 'price_text.dart';
import 'product_thumb.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAdd;
  const ProductCard({super.key, required this.product, required this.onTap, this.onAdd});
  @override State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late final AnimationController _addController;
  @override void initState() { super.initState(); _addController = AnimationController(vsync: this, duration: const Duration(milliseconds: 260)); }
  @override void dispose() { _addController.dispose(); super.dispose(); }

  void _add() async {
    await _addController.forward(from: 0);
    widget.onAdd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final category = context.read<CatalogProvider>().categoryById(widget.product.categoryId);
    final family = category?.family ?? CategoryFamily.protection;
    final scheme = Theme.of(context).colorScheme;
    final l = context.watch<AppSettingsProvider>().language;
    final user = context.watch<UserProvider>();
    final isSeller = user.role == UserRole.seller;
    final isOwn = isSeller && widget.product.sellerId == CatalogProvider.currentSellerId;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: AppColors.cardShadow(dark: isDark),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Stack(children: [
            ProductThumb(product: widget.product, family: family, height: 155),
            if (widget.product.inStock) Positioned(top: 8, right: 8, child: _Pill(text: l == AppLanguage.kyrgyz ? 'Бар' : 'В наличии', color: AppColors.green, bg: l == AppLanguage.kyrgyz ? AppColors.green.withValues(alpha: .18) : AppColors.greenTint)),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 34, child: Text(widget.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.3, color: scheme.onSurface))),
              const SizedBox(height: 8),
              if (widget.product.specs.isNotEmpty) Wrap(spacing: 4, runSpacing: 4, children: widget.product.specs.take(2).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: scheme.primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(5)),
                child: Text(s.value, style: TextStyle(fontSize: 9.5, color: scheme.primary, fontWeight: FontWeight.w500, fontFamily: 'monospace')),
              )).toList()),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                PriceText(widget.product.price, color: scheme.primary),
                if (widget.onAdd != null) GestureDetector(
                  onTap: isOwn ? () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.noOwnProductCart(l)), behavior: SnackBarBehavior.floating));
                  } : isSeller ? () async {
                    await _addController.forward(from: 0);
                    context.read<SellerOrderProvider>().addProductOrder(widget.product);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.productAddedOrder(l)), behavior: SnackBarBehavior.floating));
                  } : _add,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1, end: .82).animate(CurvedAnimation(parent: _addController, curve: Curves.easeOutBack)),
                    child: Container(width: 28, height: 28, decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(9), boxShadow: AppColors.floatingShadow(dark: isDark, tint: scheme.primary)), child: const Icon(Icons.add, color: Colors.white, size: 15)),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text; final Color color; final Color bg;
  const _Pill({required this.text, required this.color, required this.bg});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)), child: Text(text, style: TextStyle(fontSize: 8.5, color: color, fontWeight: FontWeight.w600)));
}
