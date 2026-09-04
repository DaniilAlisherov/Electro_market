import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_label.dart';
import '../../state/cart_provider.dart';
import '../../state/catalog_provider.dart';
import '../../state/app_settings_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final l = context.watch<AppSettingsProvider>().language;
    final scheme = Theme.of(context).colorScheme;
    final results = catalog.search(_query);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.search(l), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: scheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Автомат C16, УЗО, ВВГнг...',
                  hintStyle: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, size: 18, color: AppColors.inkFaint),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 120),
                children: [
                  SectionLabel(
                    _query.isEmpty
                        ? (l == AppLanguage.kyrgyz ? 'Бардык товарлар' : 'Все товары')
                        : (results.isEmpty ? (l == AppLanguage.kyrgyz ? '«$_query» боюнча эч нерсе табылган жок' : 'По запросу «$_query» ничего не найдено') : (l == AppLanguage.kyrgyz ? '«$_query»: ${results.length} товар' : 'По запросу «$_query»: ${results.length}')),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                    children: [
                      for (final p in results)
                        ProductCard(
                          product: p,
                          onTap: () => context.push('/product/${p.id}'),
                          onAdd: () => context.read<CartProvider>().add(p),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
