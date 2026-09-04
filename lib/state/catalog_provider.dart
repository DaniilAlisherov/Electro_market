import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/category.dart';
import '../models/product.dart';

/// Единая точка доступа к каталогу.
///
/// Сейчас данные берутся из mock_data.dart.
/// В дальнейшем здесь можно подключить REST API / Repository.
class CatalogProvider extends ChangeNotifier {
  CatalogProvider()
      : _products = List<Product>.from(mockProducts);

  // ============================================================
  // КОНСТАНТЫ ТЕКУЩЕГО ПРОДАВЦА
  // ============================================================

  static const String currentSellerId = 'demo-seller';
  static const String currentSellerName = 'ТД «Электрокомплект»';

  // ============================================================
  // ДАННЫЕ
  // ============================================================

  final List<ProductCategory> categories =
      List<ProductCategory>.unmodifiable(mockCategories);

  final List<Product> _products;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Все товары.
  List<Product> get products {
    return List<Product>.unmodifiable(_products);
  }

  /// Рекомендуемые товары.
  List<Product> get featured {
    return List<Product>.unmodifiable(
      _products.take(2).toList(),
    );
  }

  /// Товары текущего продавца.
  List<Product> get myProducts {
    return List<Product>.unmodifiable(
      _products.where(
        (product) => product.sellerId == currentSellerId,
      ),
    );
  }

  /// Количество всех товаров.
  int get productsCount {
    return _products.length;
  }

  /// Количество товаров текущего продавца.
  int get myProductsCount {
    return myProducts.length;
  }

  // ============================================================
  // КАТЕГОРИИ
  // ============================================================

  /// Поиск категории по ID.
  ProductCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }

    return null;
  }

  // ============================================================
  // ТОВАРЫ
  // ============================================================

  /// Поиск товара по ID.
  Product? productById(String id) {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  /// Товары определённой категории.
  List<Product> productsByCategory(String categoryId) {
    return List<Product>.unmodifiable(
      _products.where(
        (product) => product.categoryId == categoryId,
      ),
    );
  }

  // ============================================================
  // ПОИСК
  // ============================================================

  /// Поиск товара:
  ///
  /// - по названию;
  /// - по категории;
  /// - по типу;
  /// - по продавцу.
  ///
  /// Например:
  /// "розетки" найдёт товары из категории "Розетки".
  List<Product> search(String query) {
    final String q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return products;
    }

    final result = _products.where((product) {
      final String productName =
          product.name.toLowerCase();

      final String categoryName =
          categoryById(product.categoryId)
                  ?.name
                  .toLowerCase() ??
              '';

      final String type =
          product.type?.toLowerCase() ?? '';

      final String sellerName =
          product.sellerName.toLowerCase();

      return productName.contains(q) ||
          categoryName.contains(q) ||
          type.contains(q) ||
          sellerName.contains(q);
    }).toList();

    return List<Product>.unmodifiable(result);
  }

  // ============================================================
  // ДОБАВЛЕНИЕ
  // ============================================================

  /// Добавить новый товар.
  void addProduct(Product product) {
    // Если товар с таким ID уже существует,
    // не добавляем дубликат.
    if (containsProduct(product.id)) {
      return;
    }

    _products.insert(0, product);

    notifyListeners();
  }

  // ============================================================
  // ОБНОВЛЕНИЕ
  // ============================================================

  /// Обновить существующий товар.
  void updateProduct(Product updatedProduct) {
    final int index = _products.indexWhere(
      (product) => product.id == updatedProduct.id,
    );

    if (index == -1) {
      return;
    }

    _products[index] = updatedProduct;

    notifyListeners();
  }

  // ============================================================
  // УДАЛЕНИЕ
  // ============================================================

  /// Удалить товар.
  void removeProduct(String productId) {
    final int oldLength = _products.length;

    _products.removeWhere(
      (product) => product.id == productId,
    );

    if (_products.length != oldLength) {
      notifyListeners();
    }
  }

  // ============================================================
  // ПРОВЕРКИ
  // ============================================================

  /// Проверяет, существует ли товар.
  bool containsProduct(String productId) {
    return _products.any(
      (product) => product.id == productId,
    );
  }

  /// Проверяет, принадлежит ли товар текущему продавцу.
  bool isMyProduct(Product product) {
    return product.sellerId == currentSellerId;
  }

  // ============================================================
  // ВОССТАНОВЛЕНИЕ MOCK-ДАННЫХ
  // ============================================================

  /// Восстановить тестовый каталог.
  void restoreMockProducts() {
    _products
      ..clear()
      ..addAll(mockProducts);

    notifyListeners();
  }

  // ============================================================
  // ОЧИСТКА
  // ============================================================

  /// Очистить весь каталог.
  void clearProducts() {
    if (_products.isEmpty) {
      return;
    }

    _products.clear();

    notifyListeners();
  }
}