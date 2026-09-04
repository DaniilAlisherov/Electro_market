enum OrderStatus { pending, transit, delivered, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Обрабатывается';
      case OrderStatus.transit:
        return 'В пути';
      case OrderStatus.delivered:
        return 'Доставлен';
      case OrderStatus.cancelled:
        return 'Отменён';
    }
  }
}

/// Этап обработки заказа со стороны продавца. Продавец переключает его
/// кнопками в «Заказы покупателей», а покупатель сразу видит актуальный
/// статус в «Моих заказах» — это один и тот же этап, просто выведенный
/// в двух разных экранах.
enum SellerOrderStage { searching, processing, shipped, delivered, cancelled }

extension SellerOrderStageLabel on SellerOrderStage {
  String label(bool isKyrgyz) {
    switch (this) {
      case SellerOrderStage.searching:
        return isKyrgyz ? 'Буйрутма изделүүдө' : 'Заказ ищется';
      case SellerOrderStage.processing:
        return isKyrgyz ? 'Буйрутма иштелүүдө' : 'Заказ обрабатывается';
      case SellerOrderStage.shipped:
        return isKyrgyz ? 'Буйрутма жөнөтүлдү' : 'Заказ отправлен';
      case SellerOrderStage.delivered:
        return isKyrgyz ? 'Буйрутма жеткирилди' : 'Заказ доставлен';
      case SellerOrderStage.cancelled:
        return isKyrgyz ? 'Буйрутма жокко чыгарылды' : 'Заказ отменён';
    }
  }

  String shortLabel(bool isKyrgyz) {
    switch (this) {
      case SellerOrderStage.searching:
        return isKyrgyz ? 'Изделүүдө' : 'Ищется';
      case SellerOrderStage.processing:
        return isKyrgyz ? 'Иштелүүдө' : 'Обработка';
      case SellerOrderStage.shipped:
        return isKyrgyz ? 'Жөнөтүлдү' : 'Отправлен';
      case SellerOrderStage.delivered:
        return isKyrgyz ? 'Жеткирилди' : 'Доставлен';
      case SellerOrderStage.cancelled:
        return isKyrgyz ? 'Жокко чыгарылды' : 'Отменён';
    }
  }
}

/// Заказ покупателя (используется и в разделе продавца — "Заказы покупателей").
class BuyerOrder {
  final String id;
  final String summary;
  final double total;
  final OrderStatus status;
  final String? buyerName;
  final String buyerPhone;
  final DateTime? createdAt;
  /// Количество товарных позиций в заказе.
  final int itemCount;

  const BuyerOrder({
    required this.id,
    required this.summary,
    required this.total,
    required this.status,
    this.buyerName,
    this.buyerPhone = '',
    this.createdAt,
    this.itemCount = 0,
  });
}

class ReturnRequest {
  final String orderId;
  final String reason;
  final double amount;
  final OrderStatus status;

  const ReturnRequest({
    required this.orderId,
    required this.reason,
    required this.amount,
    required this.status,
  });
}

class Address {
  final String label;
  final String details;

  const Address({required this.label, required this.details});
}


class ReceiptItem {
  final String name;
  final int quantity;
  final double total;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.total,
  });
}

class OrderReceipt {
  final String orderId;
  final String code;
  final DateTime createdAt;
  final List<ReceiptItem> items;
  final double subtotal;
  final double delivery;
  final double total;

  const OrderReceipt({
    required this.orderId,
    required this.code,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.delivery,
    required this.total,
  });

  String get qrData => 'CHECK:$code|ORDER:$orderId';
}
