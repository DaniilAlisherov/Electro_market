import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/product.dart';

/// Показывает фото товара везде одинаково:
/// 1) реальное фото, загруженное продавцом (байты — работает на всех платформах);
/// 2) если своего фото ещё нет — фотозаглушка с fotoseed, детерминированная
///    по id товара (у карточки всегда одна и та же картинка, а не случайная
///    при каждой перерисовке);
/// 3) если нет сети/картинка не загрузилась — цветная иллюстрация по
///    категории (медь/синий/графит + иконка), чтобы карточка никогда не
///    оставалась пустой.
///
/// ВАЖНО: фотозаглушки (Lorem Picsum) — временное решение для витрины,
/// пока у товаров нет собственных фото. Перед публикацией в сторах их нужно
/// заменить на настоящие фото товаров (через forceRealPhoto/imageBytes —
/// то есть продавцы просто загружают фото через форму, и оно автоматически
/// подставится вместо заглушки).
class ProductThumb extends StatelessWidget {
  final Product product;
  final CategoryFamily family;
  final double height;
  final BorderRadius? borderRadius;

  const ProductThumb({
    super.key,
    required this.product,
    required this.family,
    this.height = 100,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final scheme = Theme.of(context).colorScheme;

    if (product.imageBytes != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.memory(
          product.imageBytes!,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    // Поддерживаем несколько вариантов расположения ассетов, чтобы
    // фотографии из assets/product тоже автоматически подхватывались.
    final paths = [
      if (product.id == 'rele24b') 'assets/images/product/rele24b.jpg',
      // Основная папка, как ты указал: assets/images/product/
      'assets/images/product/${product.id}.jpg',
      'assets/images/product/${product.id}.jpeg',
      'assets/images/product/${product.id}.png',
      'assets/images/product/${product.id}.webp',
      // Также поддерживаем уже существующие варианты папок.
      'assets/images/products/${product.id}.jpg',
      'assets/images/products/${product.id}.jpeg',
      'assets/images/products/${product.id}.png',
      'assets/images/products/${product.id}.webp',
      'assets/product/${product.id}.jpg',
      'assets/product/${product.id}.jpeg',
      'assets/product/${product.id}.png',
      'assets/product/${product.id}.webp',
      'assets/products/${product.id}.jpg',
      'assets/products/${product.id}.jpeg',
      'assets/products/${product.id}.png',
      'assets/products/${product.id}.webp',
    ];

    return ClipRRect(
      borderRadius: radius,
      child: _ProductAssetCandidate(
        paths: paths,
        height: height,
        fallback: _Placeholder(
          family: family,
          icon: product.fallbackIcon,
          height: height,
          primary: scheme.primary,
        ),
      ),
    );
  }
}

class _ProductAssetCandidate extends StatelessWidget {
  final List<String> paths;
  final double height;
  final Widget fallback;
  final int index;

  const _ProductAssetCandidate({
    required this.paths,
    required this.height,
    required this.fallback,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (index >= paths.length) return fallback;
    return Image.asset(
      paths[index],
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => _ProductAssetCandidate(
        paths: paths,
        height: height,
        fallback: fallback,
        index: index + 1,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final CategoryFamily family;
  final IconData icon;
  final double height;
  final Color primary;

  const _Placeholder({
    required this.family,
    required this.icon,
    required this.height,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [const Color(0xFF0C1420), const Color(0xFF0A0E14)]
              : [family.tint, family.tint.withValues(alpha: .55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: height * 0.34,
        color: dark ? primary : family.color,
      ),
    );
  }
}
