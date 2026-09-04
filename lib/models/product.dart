import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Одна строка технической характеристики (Ток — 16А, Напряжение — 230В...).
/// Список произвольной длины — так каталог поддерживает любые новые типы
/// товаров без изменения модели или экранов.
class ProductSpec {
  final String label;
  final String value;
  const ProductSpec(this.label, this.value);
}

class Product {
  final String id;
  final String name;
  final String categoryId;
  final String? type;
  final double price;
  final double? oldPrice;
  final int stock;
  final List<ProductSpec> specs;
  final String description;
  final String sellerId;
  final String sellerName;
  final double rating;
  final int reviewsCount;

  /// Фото, добавленное продавцом. Хранится как байты (а не путь к файлу),
  /// потому что `dart:io File` работает не на всех платформах (например,
  /// не работает в вебе) — байты одинаково рендерятся через Image.memory
  /// везде: Android, iOS, Web, Windows/macOS/Linux.
  final Uint8List? imageBytes;
  final IconData fallbackIcon;

  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    this.type,
    required this.price,
    this.oldPrice,
    required this.stock,
    this.specs = const [],
    this.description = '',
    required this.sellerId,
    required this.sellerName,
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.imageBytes,
    required this.fallbackIcon,
  });

  bool get inStock => stock > 0;

  Product copyWith({
    List<ProductSpec>? specs,
    Uint8List? imageBytes,
  }) {
    return Product(
      id: id,
      name: name,
      categoryId: categoryId,
      type: type,
      price: price,
      oldPrice: oldPrice,
      stock: stock,
      specs: specs ?? this.specs,
      description: description,
      sellerId: sellerId,
      sellerName: sellerName,
      rating: rating,
      reviewsCount: reviewsCount,
      imageBytes: imageBytes ?? this.imageBytes,
      fallbackIcon: fallbackIcon,
    );
  }
}
