import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bolt_rating.dart';
import '../../../state/app_settings_provider.dart';
import '../../../state/catalog_provider.dart';
import '../../../state/review_provider.dart';

/// Раздел продавца: отзывы покупателей обо всех его товарах, сгруппированные
/// по товару. Заходит из профиля продавца ("Отзывы о товарах").
class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppSettingsProvider>().language;
    final isKyrgyz = l == AppLanguage.kyrgyz;
    final catalog = context.watch<CatalogProvider>();
    final reviewProvider = context.watch<ReviewProvider>();

    final myProducts = catalog.myProducts;
    final myProductIds = myProducts.map((p) => p.id).toSet();
    final reviews = reviewProvider.forProducts(myProductIds);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.productReviews(l))),
      body: reviews.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  AppStrings.noReviewsYet(l),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                for (final product in myProducts)
                  if (reviewProvider.forProduct(product.id).isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(product.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                          ),
                          BoltRating(rating: reviewProvider.averageFor(product.id), size: 13),
                        ],
                      ),
                    ),
                    for (final r in reviewProvider.forProduct(product.id))
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.line),
                          boxShadow: AppColors.softShadow(dark: Theme.of(context).brightness == Brightness.dark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(r.buyerName, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                BoltRating(rating: r.rating.toDouble(), size: 13),
                              ],
                            ),
                            if (r.comment.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(r.comment, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4)),
                            ],
                          ],
                        ),
                      ),
                  ],
              ],
            ),
    );
  }
}