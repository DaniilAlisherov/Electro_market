import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/order.dart';
import '../models/product.dart';

class SellerOrderDraft {
  final String id;
  final Product product;
  final int quantity;
  final DateTime createdAt;
  SellerOrderDraft({required this.id, required this.product, required this.quantity, required this.createdAt});
}

class SellerOrderProvider extends ChangeNotifier {
  final List<SellerOrderDraft> _drafts = [];
  List<SellerOrderDraft> get drafts => List.unmodifiable(_drafts);

  /// Живые заказы, созданные покупателями во время оформления.
  final List<BuyerOrder> _liveOrders = [];
  List<BuyerOrder> get liveOrders => List.unmodifiable(_liveOrders);

  final Map<String, OrderReceipt> _receipts = {};

  OrderReceipt? receiptFor(String orderId) => _receipts[orderId];

  OrderReceipt? receiptByCode(String value) {
    final normalized = value.trim().toUpperCase().replaceFirst('#', '');
    if (normalized.isEmpty) return null;
    for (final receipt in _receipts.values) {
      if (receipt.code.toUpperCase() == normalized) return receipt;
      if (receipt.qrData.toUpperCase() == normalized) return receipt;
    }
    return null;
  }

  final Map<String, SellerOrderStage> _stages = {
    for (final o in mockSellerOrders) o.id: _initialStage(o.status),
  };

  static SellerOrderStage _initialStage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return SellerOrderStage.processing;
      case OrderStatus.transit: return SellerOrderStage.shipped;
      case OrderStatus.delivered: return SellerOrderStage.delivered;
      case OrderStatus.cancelled: return SellerOrderStage.cancelled;
    }
  }

  void addProductOrder(Product product, {int quantity = 1}) {
    _drafts.insert(0, SellerOrderDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      product: product,
      quantity: quantity,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Создаёт один заказ в общей модели: его видит и покупатель, и единственный продавец.
  String createBuyerOrder({
    required String summary,
    required double total,
    required String buyerName,
    String buyerPhone = '',
    int itemCount = 0,
    List<ReceiptItem> receiptItems = const [],
    double delivery = 0,
  }) {
    final id = (DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
    final order = BuyerOrder(
      id: id,
      summary: summary,
      total: total,
      status: OrderStatus.pending,
      buyerName: buyerName.isEmpty ? 'Покупатель' : buyerName,
      buyerPhone: buyerPhone,
      createdAt: DateTime.now(),
      itemCount: itemCount,
    );
    _liveOrders.insert(0, order);

    final createdAt = order.createdAt ?? DateTime.now();
    final receiptCode = 'CHK-$id';
    final receiptSubtotal = receiptItems.isEmpty
        ? (total - delivery).clamp(0, double.infinity).toDouble()
        : receiptItems.fold<double>(0, (sum, item) => sum + item.total);
    _receipts[id] = OrderReceipt(
      orderId: id,
      code: receiptCode,
      createdAt: createdAt,
      items: List.unmodifiable(receiptItems),
      subtotal: receiptSubtotal,
      delivery: delivery,
      total: total,
    );

    _stages[id] = SellerOrderStage.processing;
    notifyListeners();
    return id;
  }

  SellerOrderStage stageFor(String orderId) => _stages[orderId] ?? SellerOrderStage.searching;
  bool hasStage(String orderId) => _stages.containsKey(orderId);

  void setStage(String orderId, SellerOrderStage stage) {
    if (_stages[orderId] == stage) return;
    _stages[orderId] = stage;
    notifyListeners();
  }

  final Map<String, SellerOrderStage> _draftStages = {};
  SellerOrderStage draftStageFor(String draftId) => _draftStages[draftId] ?? SellerOrderStage.searching;

  void setDraftStage(String draftId, SellerOrderStage stage) {
    if (_draftStages[draftId] == stage) return;
    _draftStages[draftId] = stage;
    notifyListeners();
  }
}
