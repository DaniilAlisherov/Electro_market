import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/category_thumb.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_label.dart';
import '../../models/category.dart';
import '../../state/cart_provider.dart';
import '../../state/catalog_provider.dart';
import '../../state/app_settings_provider.dart';
import '../../state/user_provider.dart';
import '../../models/user_role.dart';
import '../../state/seller_order_provider.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final l = context.watch<AppSettingsProvider>().language;
    final scheme = Theme.of(context).colorScheme;
    final role = context.watch<UserProvider>().role;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.copperLight, AppColors.copper], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(AppStrings.appName(l), style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.go('/search'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
                boxShadow: AppColors.softShadow(dark: Theme.of(context).brightness == Brightness.dark),
              ),
              child: Row(children: [Icon(Icons.search, size: 18, color: scheme.onSurfaceVariant), const SizedBox(width: 9), Text('Автомат C16, УЗО, ВВГнг...', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant))]),
            ),
          ),
          const SizedBox(height: 14),
          _HelpChoiceCard(language: l),
          SectionLabel(AppLanguage == AppLanguage.kyrgyz ? 'Категориялар' : 'Категории'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.92,
            children: [
              for (final c in catalog.categories) _CategoryTile(category: c, onTap: () => _openCategory(context, c.id)),
              _MoreTile(onTap: () => _openCategory(context, catalog.categories.first.id)),
            ],
          ),
          const SizedBox(height: 14),
          _Legend(language: l),
          SectionLabel(AppLanguage == AppLanguage.kyrgyz ? 'Ушул жумадагы популярдуу товарлар' : 'Популярное на этой неделе'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
            children: [
              for (final p in catalog.featured)
                ProductCard(
                  product: p,
                  onTap: () => context.push('/product/${p.id}'),
                  onAdd: () {
                    if (role == UserRole.seller) {
                      if (p.sellerId == CatalogProvider.currentSellerId) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.noOwnProductCart(l)), behavior: SnackBarBehavior.floating));
                      } else {
                        context.read<SellerOrderProvider>().addProductOrder(p);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.productAddedOrder(l)), behavior: SnackBarBehavior.floating));
                      }
                    } else {
                      context.read<CartProvider>().add(p);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openCategory(BuildContext context, String categoryId) {
    context.push('/category/$categoryId');
  }
}

class _HelpChoiceCard extends StatelessWidget {
  final AppLanguage language;
  const _HelpChoiceCard({required this.language});

  @override
  Widget build(BuildContext context) {
    final isKyrgyz = language == AppLanguage.kyrgyz;
    final scheme = Theme.of(context).colorScheme;
    final items = isKyrgyz
        ? const [
            (Icons.shield_outlined, 'Коргоо'),
            (Icons.cable_outlined, 'Кабель'),
            (Icons.power_outlined, 'Розеткалар'),
            (Icons.lightbulb_outline, 'Жарыктандыруу'),
          ]
        : const [
            (Icons.shield_outlined, 'Защита'),
            (Icons.cable_outlined, 'Кабель'),
            (Icons.power_outlined, 'Розетки'),
            (Icons.lightbulb_outline, 'Освещение'),
          ];

    void openHelp() => context.push('/chats/support');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2027), Color(0xFF262C34)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isKyrgyz ? 'ТАНДООГО ЖАРДАМ' : 'ПОМОЧЬ С ВЫБОРОМ',
                      style: const TextStyle(fontSize: 10, letterSpacing: 1.1, color: AppColors.copperLight, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isKyrgyz ? 'Кайсы бөлүм боюнча жардам керек?' : 'По какой категории нужна помощь?',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: openHelp,
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary.withValues(alpha: .16),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                InkWell(
                  onTap: openHelp,
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .075),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white.withValues(alpha: .10)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.$1, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(item.$2, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: openHelp,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isKyrgyz ? 'Чатка өтүү' : 'Открыть чат', style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(width: 5),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ProductCategory category;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final role = context.watch<UserProvider>().role;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark),
        ),
        clipBehavior: Clip.antiAlias,
        child: CategoryThumb(category: category, borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final VoidCallback onTap;
  const _MoreTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.more_horiz, color: Colors.white70),
            SizedBox(height: 6),
            Text('Ещё', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final AppLanguage language;
  const _Legend({required this.language});

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.inkFaint, fontFamily: 'monospace')),
        ]);
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(children: [
        dot(AppColors.copper, language == AppLanguage.kyrgyz ? 'Коргоо' : 'Защита'),
        const SizedBox(width: 14),
        dot(AppColors.blue, language == AppLanguage.kyrgyz ? 'Монтаж' : 'Монтаж'),
        const SizedBox(width: 14),
        dot(AppColors.graphite, language == AppLanguage.kyrgyz ? 'Жасалгалоо' : 'Отделка'),
      ]),
    );
  }
}
