import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/product_card.dart';
import '../../../state/cart_provider.dart';
import '../../../state/catalog_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Демо: показываем часть каталога как избранное покупателя.
    final favorites = context.watch<CatalogProvider>().products.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: favorites.isEmpty
            ? const Center(child: Text('Пока пусто'))
            : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
                children: [
                  for (final p in favorites)
                    ProductCard(
                      product: p,
                      onTap: () => context.push('/product/${p.id}'),
                      onAdd: () => context.read<CartProvider>().add(p),
                    ),
                ],
              ),
      ),
    );
  }
}
