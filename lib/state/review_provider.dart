import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/review.dart';

/// Отзывы покупателей о товарах. Покупатель оставляет отзыв на странице
/// товара, продавец видит все отзывы о своих товарах в профиле
/// (раздел «Отзывы о товарах»).
class ReviewProvider extends ChangeNotifier {
  final List<Review> _reviews = List.of(mockReviews);

  List<Review> get reviews => List.unmodifiable(_reviews);

  List<Review> forProduct(String productId) =>
      _reviews.where((r) => r.productId == productId).toList();

  /// Отзывы обо всех товарах из [productIds] — используется в профиле
  /// продавца, чтобы показать отзывы только о его собственных товарах.
  List<Review> forProducts(Set<String> productIds) =>
      _reviews.where((r) => productIds.contains(r.productId)).toList();

  double averageFor(String productId) {
    final list = forProduct(productId);
    if (list.isEmpty) return 0;
    return list.map((r) => r.rating).reduce((a, b) => a + b) / list.length;
  }

  void addReview(Review review) {
    _reviews.insert(0, review);
    notifyListeners();
  }
}
