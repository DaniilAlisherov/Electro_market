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
import '../../state/user_provider.dart';
import '../../models/user_role.dart';
import '../../models/review.dart';
import '../../state/seller_order_provider.dart';
import '../../state/review_provider.dart';
import '../../core/widgets/bolt_rating.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  int _myRating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final l = context.watch<AppSettingsProvider>().language;
    final isKyrgyz = l == AppLanguage.kyrgyz;
    final scheme = Theme.of(context).colorScheme;
    final product = catalog.productById(widget.productId);
    final user = context.watch<UserProvider>();
    final isSeller = user.role == UserRole.seller;
    final isOwnProduct = isSeller && product != null && product.sellerId == CatalogProvider.currentSellerId;
    final reviews = product == null ? <Review>[] : context.watch<ReviewProvider>().forProduct(product.id);

    if (product == null) {
      return Scaffold(body: Center(child: Text(l == AppLanguage.kyrgyz ? 'Товар табылган жок' : 'Товар не найден')));
    }

    final category = catalog.categoryById(product.categoryId);
    final family = category?.family ?? CategoryFamily.protection;

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 110),
            children: [
              ProductThumb(product: product, family: family, height: 250),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.25)),
                    const SizedBox(height: 6),
                    Row(children: [
                      BoltRating(rating: product.rating, size: 14),
                      const SizedBox(width: 4),
                      Text('${product.rating}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      const SizedBox(width: 6),
                      Text('· ${product.sellerName}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    ]),
                    const SizedBox(height: 16),
                    Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                      PriceText(product.price, size: 26),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 10),
                        Text('${product.oldPrice!.toStringAsFixed(0)} сом', style: TextStyle(decoration: TextDecoration.lineThrough, color: scheme.onSurfaceVariant, fontSize: 13)),
                      ],
                    ]),
                    const SizedBox(height: 18),
                    if (product.specs.isNotEmpty) ...[
                      Text(l == AppLanguage.kyrgyz ? 'МҮНӨЗДӨМӨЛӨР' : 'ХАРАКТЕРИСТИКИ', style: TextStyle(fontSize: 10.5, letterSpacing: 1, color: scheme.onSurfaceVariant, fontFamily: 'monospace')),
                      const SizedBox(height: 6),
                      ...product.specs.map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(s.label, style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                                Text(s.value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                              ],
                            ),
                          )),
                      Divider(height: 24, color: scheme.outlineVariant),
                    ],
                    if (product.description.isNotEmpty) ...[
                      Text(product.description, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant, height: 1.5)),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.copperLight, AppColors.copper]), borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.center,
                            child: Text(product.sellerName.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.sellerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text(l == AppLanguage.kyrgyz ? '${product.rating} · ${product.reviewsCount} пикир' : '${product.rating} · ${product.reviewsCount} отзывов', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      isKyrgyz ? 'ПИКИРЛЕР' : 'ОТЗЫВЫ',
                      style: TextStyle(fontSize: 10.5, letterSpacing: 1, color: scheme.onSurfaceVariant, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 10),

                    // Форма отзыва — доступна только покупателю и только не
                    // для собственного товара (продавец не оценивает себя).
                    if (!isSeller && !isOwnProduct)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.yourRating(l), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            BoltRatingInput(value: _myRating, onChanged: (v) => setState(() => _myRating = v)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _commentController,
                              minLines: 2,
                              maxLines: 4,
                              style: const TextStyle(fontSize: 12.5),
                              decoration: InputDecoration(
                                hintText: AppStrings.reviewCommentHint(l),
                                hintStyle: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {
                                  if (_myRating == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppStrings.selectRatingFirst(l)), behavior: SnackBarBehavior.floating),
                                    );
                                    return;
                                  }
                                  context.read<ReviewProvider>().addReview(Review(
                                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                                        productId: product.id,
                                        buyerName: user.name,
                                        rating: _myRating,
                                        comment: _commentController.text.trim(),
                                      ));
                                  setState(() {
                                    _myRating = 0;
                                    _commentController.clear();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppStrings.reviewSubmitted(l)), behavior: SnackBarBehavior.floating),
                                  );
                                },
                                child: Text(AppStrings.submitReview(l)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(AppStrings.noReviewsYet(l), style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                      )
                    else
                      ...reviews.map((r) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: scheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
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
                                  Text(r.comment, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, height: 1.4)),
                                ],
                              ],
                            ),
                          )),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 12,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: scheme.surfaceContainer,
                child: IconButton(icon: const Icon(Icons.arrow_back, size: 18), onPressed: () => context.pop()),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(11)),
                      child: Row(
                        children: [
                          IconButton(onPressed: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1), icon: const Icon(Icons.remove, size: 16)),
                          Text('$_qty', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                          IconButton(onPressed: () => setState(() => _qty++), icon: const Icon(Icons.add, size: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isOwnProduct) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppStrings.noOwnProductCart(l)), behavior: SnackBarBehavior.floating),
                            );
                            return;
                          }
                          if (isSeller) {
                            context.read<SellerOrderProvider>().addProductOrder(product, quantity: _qty);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppStrings.productAddedOrder(l)), behavior: SnackBarBehavior.floating),
                            );
                            return;
                          }
                          context.read<CartProvider>().add(product, quantity: _qty);
                          context.push('/checkout');
                        },
                        icon: Icon(isSeller ? Icons.add_task_rounded : Icons.shopping_bag_outlined, size: 17),
                        label: Text(isOwnProduct ? (l == AppLanguage.kyrgyz ? 'Өз товарыңыз' : 'Ваш товар') : isSeller ? AppStrings.sellerAddOrder(l) : (l == AppLanguage.kyrgyz ? 'Сатып алуу' : 'Купить')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
