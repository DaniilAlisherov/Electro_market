import 'package:flutter/material.dart';

/// Смысловая "семья" категории — определяет цвет иконки в сетке каталога.
enum CategoryFamily { protection, wiring, fitting }

extension CategoryFamilyColor on CategoryFamily {
  Color get color {
    switch (this) {
      case CategoryFamily.protection:
        return const Color(0xFF2A4494); // синий (индиго) — семья "защита"
      case CategoryFamily.wiring:
        return const Color(0xFF123A73); // blueDark — семья "монтаж"
      case CategoryFamily.fitting:
        return const Color(0xFF33383F); // graphite
    }
  }

  Color get tint {
    switch (this) {
      case CategoryFamily.protection:
        return const Color(0xFFE9ECFA);
      case CategoryFamily.wiring:
        return const Color(0xFFE4EEF9);
      case CategoryFamily.fitting:
        return const Color(0xFFEAEBEC);
    }
  }
}

/// Категория товара. Новые категории (щиты, автоматы, УЗО, кабель, провода,
/// реле, корпуса, DIN-рейки, розетки, выключатели, светильники и т.д.)
/// добавляются просто новыми элементами списка в data/mock_data.dart —
/// экраны каталога их подхватывают автоматически.
class ProductCategory {
  final String id;
  final String name;
  final IconData icon;
  final CategoryFamily family;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.family,
  });
}
