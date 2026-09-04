import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/product_card.dart';
import '../../../state/catalog_provider.dart';
import '../../../state/app_settings_provider.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _addController;

  @override
  void initState() {
    super.initState();
    _addController = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    await _addController.forward(from: 0);
    if (mounted) context.push('/my-products/add');
  }

  @override
  Widget build(BuildContext context) {
    final myProducts = context.watch<CatalogProvider>().myProducts;
    final l = context.watch<AppSettingsProvider>().language;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.myProducts(l))),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAdd,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                icon: AnimatedBuilder(animation: _addController, builder: (_, child) => Transform.rotate(angle: _addController.value * 0.35, child: child), child: const Icon(Icons.add, size: 16)),
                label: Text(l == AppLanguage.kyrgyz ? 'Товар кошуу' : 'Добавить товар'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: myProducts.isEmpty
                  ? Center(child: Text(l == AppLanguage.kyrgyz ? 'Азырынча товарларыңыз жок' : 'У вас пока нет товаров', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                  : GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                      children: [
                        for (final p in myProducts)
                          ProductCard(product: p, onTap: () => context.push('/product/${p.id}')),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
