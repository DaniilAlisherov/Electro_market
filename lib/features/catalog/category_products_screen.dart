import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_label.dart';
import '../../state/cart_provider.dart';
import '../../state/catalog_provider.dart';
import '../../state/app_settings_provider.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryId;
  const CategoryProductsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final l = context.watch<AppSettingsProvider>().language;
    final scheme = Theme.of(context).colorScheme;
    final category = catalog.categoryById(categoryId);
    final items = catalog.productsByCategory(categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(category == null ? (l == AppLanguage.kyrgyz ? 'Категория' : 'Категория') : AppStrings.categoryName(l, category.id, category.name))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          SectionLabel(l == AppLanguage.kyrgyz ? '${items.length} товар' : '${items.length} товаров'),
          if (items.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Center(child: Text(l == AppLanguage.kyrgyz ? 'Бул категорияда азырынча товар жок' : 'В этой категории пока нет товаров', style: TextStyle(color: scheme.onSurfaceVariant))))
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
              children: [
                for (final p in items)
                  ProductCard(
                    product: p,
                    onTap: () => context.push('/product/${p.id}'),
                    onAdd: () => context.read<CartProvider>().add(p),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
