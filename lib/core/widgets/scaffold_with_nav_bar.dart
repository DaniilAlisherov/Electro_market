import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../../state/cart_provider.dart';
import '../../state/app_settings_provider.dart';
import '../../state/user_provider.dart';
import '../../models/user_role.dart';

/// Основной нижний бар в стиле iOS: плавающая панель, мягкая подсветка
/// выбранной вкладки, spring-анимация и лёгкий haptic feedback.
class ScaffoldWithNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.navigationShell.currentIndex;
    if (oldWidget.navigationShell.currentIndex != newIndex) {
      _pageController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    final isSeller = context.read<UserProvider>().role == UserRole.seller;

    if (isSeller) {
      if (index == 2) {
        context.push('/my-products/add');
        return;
      }
      // У продавца вкладка «Заказы» — отдельный экран поверх шелла,
      // а не branch стека, поэтому переключаем не через goBranch.
      if (index == 3) {
        HapticFeedback.selectionClick();
        context.push('/seller-orders');
        return;
      }
    }

    // У продавца индекс вкладки "Профиль" в баре (4) сдвинут из-за
    // добавленной вкладки "Заказы", а branch у неё по-прежнему третий (0..3).
    final branchIndex = (isSeller && index == 4) ? 3 : index;

    if (branchIndex == widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(branchIndex, initialLocation: true);
      return;
    }

    HapticFeedback.selectionClick();
    widget.navigationShell.goBranch(branchIndex, initialLocation: false);
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalCount;
    final language = context.watch<AppSettingsProvider>().language;
    final navigationShell = widget.navigationShell;
    final role = context.watch<UserProvider>().role;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: _pageController,
          curve: Curves.easeOutCubic,
        ),
        child: navigationShell,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: _FloatingNavBar(
          // У продавца добавлена вкладка "Заказы" перед "Профилем", поэтому
          // индекс Профиля в панели (4) отличается от индекса его branch'а
          // в шелле (3). У покупателя всё как раньше — индексы совпадают.
          currentIndex: role == UserRole.seller
              ? (navigationShell.currentIndex == 3 ? 4 : navigationShell.currentIndex)
              : navigationShell.currentIndex,
          cartCount: cartCount,
          language: language,
          isSeller: role == UserRole.seller,
          onTap: _onTap,
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final AppLanguage language;
  final bool isSeller;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.cartCount,
    required this.language,
    required this.isSeller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0C1118).withValues(alpha: .98) : Colors.white.withValues(alpha: .97),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dark ? const Color(0xFF1B2A3D) : AppColors.lineSoft),
        boxShadow: [
          BoxShadow(
            color: dark ? scheme.primary.withValues(alpha: .12) : Colors.black.withValues(alpha: .16),
            blurRadius: 30,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: dark ? Colors.black.withValues(alpha: .5) : Colors.black.withValues(alpha: .06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: AppStrings.catalog(language),
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            label: AppStrings.search(language),
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: isSeller ? Icons.add_circle_outline_rounded : Icons.shopping_bag_outlined,
            label: isSeller ? AppStrings.sellerAddOrder(language) : AppStrings.cart(language),
            selected: currentIndex == 2,
            onTap: () => onTap(2),
            badgeCount: isSeller ? 0 : cartCount,
          ),
          // Вкладка "Заказы" — только для продавца.
          if (isSeller)
            _NavItem(
              icon: Icons.receipt_long_outlined,
              label: AppStrings.ordersTab(language),
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: AppStrings.profile(language),
            selected: currentIndex == (isSeller ? 4 : 3),
            onTap: () => onTap(isSeller ? 4 : 3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary.withValues(alpha: .10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 22,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutBack,
                        scale: selected ? 1.10 : 1.0,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          ),
                          child: Icon(
                            icon,
                            key: ValueKey('$icon-$selected'),
                            size: 19,
                            color: color,
                          ),
                        ),
                      ),
                      if (badgeCount > 0)
                        Positioned(
                          top: -5,
                          right: -8,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) => ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ),
                              child: child,
                            ),
                            child: Container(
                              key: ValueKey(badgeCount),
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: AppColors.floatingShadow(dark: dark, tint: scheme.primary),
                              ),
                              child: Text(
                                '$badgeCount',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
