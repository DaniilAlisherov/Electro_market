/// Отзыв покупателя о товаре. Оценка — от 0 до 5, отображается значками
/// молнии вместо привычных звёзд (фирменная деталь ЭлектроМаркета).
class Review {
  final String id;
  final String productId;
  final String buyerName;
  final int rating; // 0..5
  final String comment;

  const Review({
    required this.id,
    required this.productId,
    required this.buyerName,
    required this.rating,
    required this.comment,
  });
}
