class PaymentCard {
  final String id;
  final String holder;
  final String last4;
  final String brand;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.holder,
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });
}
