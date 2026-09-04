import 'package:flutter/material.dart';
import '../../models/category.dart';
import 'package:provider/provider.dart';
import '../../state/app_settings_provider.dart';

/// Карточка категории.
///
/// Фото категории берётся из `assets/images/categories/`.
/// Основное имя файла совпадает с `category.id`:
/// panels, breakers, rcd, cable, relay, din, sockets, switches, lights.
/// Поддерживаются .jpg, .jpeg, .png и .webp.
///
/// Фото заполняет всю карточку, а снизу добавляется мягкий градиент,
/// чтобы название оставалось хорошо читаемым.
class CategoryThumb extends StatelessWidget {
  final ProductCategory category;
  final BorderRadius borderRadius;

  const CategoryThumb({
    super.key,
    required this.category,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppSettingsProvider>().language;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Фото занимает всю карточку.
          _CategoryImage(category: category),

          // Лёгкое затемнение снизу для текста.
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x08000000),
                      Color(0xB8000000),
                    ],
                    stops: [0.45, 0.68, 1],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 8,
            right: 8,
            bottom: 9,
            child: Text(
              AppStrings.categoryName(language, category.id, category.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.18,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    offset: Offset(0, 1),
                    color: Color(0x66000000),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final ProductCategory category;

  const _CategoryImage({required this.category});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _AssetCandidate(
      paths: [
        'assets/images/categories/${category.id}.jpg',
        'assets/images/categories/${category.id}.jpeg',
        'assets/images/categories/${category.id}.png',
        'assets/images/categories/${category.id}.webp',
      ],
      fallback: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF0C1420), const Color(0xFF0A0E14)]
                : [category.family.tint, category.family.tint.withValues(alpha: .55)],
          ),
        ),
        child: Center(
          child: Icon(
            category.icon,
            size: 36,
            color: Theme.of(context).brightness == Brightness.dark ? scheme.primary : category.family.color,
          ),
        ),
      ),
    );
  }
}

class _AssetCandidate extends StatelessWidget {
  final List<String> paths;
  final Widget fallback;
  final int index;

  const _AssetCandidate({
    required this.paths,
    required this.fallback,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (index >= paths.length) return fallback;

    return Image.asset(
      paths[index],
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return _AssetCandidate(
          paths: paths,
          fallback: fallback,
          index: index + 1,
        );
      },
    );
  }
}
