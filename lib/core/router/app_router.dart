import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/scaffold_with_nav_bar.dart';
import '../../state/user_provider.dart';
import '../../features/auth/role_gate_screen.dart';
import '../../features/auth/buyer_login_screen.dart';
import '../../features/auth/seller_login_screen.dart';
import '../../features/catalog/catalog_screen.dart';
import '../../features/catalog/category_products_screen.dart';
import '../../features/catalog/product_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/profile/change_password_screen.dart';
import '../../features/profile/buyer/payment_screen.dart';
import '../../features/checkout_screen.dart';
import '../../features/profile/buyer/orders_screen.dart';
import '../../features/profile/buyer/order_detail_screen.dart';
import '../../features/profile/buyer/favorites_screen.dart';
import '../../features/profile/buyer/addresses_screen.dart';
import '../../features/profile/buyer/address_form_screen.dart';
import '../../features/profile/buyer/returns_screen.dart';
import '../../features/profile/chats_screen.dart';
import '../../features/profile/seller/my_products_screen.dart';
import '../../features/profile/seller/add_product_screen.dart';
import '../../features/profile/seller/analytics_screen.dart';
import '../../features/profile/seller/seller_orders_screen.dart';
import '../../features/profile/seller/seller_order_detail_screen.dart';
import '../../features/profile/seller/product_reviews_screen.dart';
import '../../features/support/support_screen.dart';
import '../../features/receipt_screen.dart';
import '../../features/receipt_verify_screen.dart';
import '../../features/receipt_scanner_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _authPaths = {'/', '/login/buyer', '/login/seller'};

/// Единая плавная анимация перехода (лёгкое всплытие + затухание) — чтобы
/// все переходы между экранами выглядели одинаково мягко, а не мигали
/// платформенным переходом по умолчанию.
CustomTransitionPage<void> _smoothPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 340),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0.045, 0.02),
        end: Offset.zero,
      ).animate(curved);

      final scale = Tween<double>(
        begin: 0.985,
        end: 1.0,
      ).animate(curved);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      );
    },
  );
}

/// Роутер строится с [userProvider], чтобы редирект знал, авторизован ли
/// человек и в какой роли: продавец вошёл по секретному коду, покупатель —
/// по номеру телефона. Пока не авторизован — доступны только экраны входа.
GoRouter buildAppRouter(UserProvider userProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: userProvider,
    redirect: (context, state) {
      final loggedIn = userProvider.isAuthenticated;
      final onAuthScreen = _authPaths.contains(state.matchedLocation);

      if (!loggedIn && !onAuthScreen) return '/';
      if (loggedIn && onAuthScreen) return '/catalog';
      return null;
    },
    routes: [
      GoRoute(path: '/', pageBuilder: (c, s) => _smoothPage(const RoleGateScreen(), s)),
      GoRoute(path: '/login/buyer', pageBuilder: (c, s) => _smoothPage(const BuyerLoginScreen(), s)),
      GoRoute(path: '/login/seller', pageBuilder: (c, s) => _smoothPage(const SellerLoginScreen(), s)),

      // 4 постоянные вкладки с сохранением состояния каждой (IndexedStack),
      // плавное перекрестное затухание при переключении — см. ScaffoldWithNavBar.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/catalog', builder: (c, s) => const CatalogScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/search', builder: (c, s) => const SearchScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/cart', builder: (c, s) => const CartScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen())]),
        ],
      ),

      // Экраны, открывающиеся поверх вкладок (со своей кнопкой "назад").
      GoRoute(
        path: '/category/:categoryId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (c, s) => _smoothPage(CategoryProductsScreen(categoryId: s.pathParameters['categoryId']!), s),
      ),
      GoRoute(
        path: '/product/:productId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (c, s) => _smoothPage(ProductDetailScreen(productId: s.pathParameters['productId']!), s),
      ),

      // Раздел покупателя
      GoRoute(path: '/orders', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const OrdersScreen(), s)),
      GoRoute(path: '/orders/:orderId', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(BuyerOrderDetailScreen(orderId: s.pathParameters['orderId']!), s)),
      GoRoute(path: '/favorites', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const FavoritesScreen(), s)),
      GoRoute(path: '/addresses', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const AddressesScreen(), s)),
      GoRoute(path: '/addresses/edit', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const AddressFormScreen(), s)),
      GoRoute(path: '/returns', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const ReturnsScreen(), s)),

      // Профиль — общее для обеих ролей
      GoRoute(path: '/settings', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const SettingsScreen(), s)),
      GoRoute(path: '/change-password', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const ChangePasswordScreen(), s)),
      GoRoute(path: '/payments', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const PaymentScreen(), s)),
      GoRoute(path: '/checkout', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const CheckoutScreen(), s)),
      GoRoute(path: '/receipt/:orderId', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(ReceiptScreen(orderId: s.pathParameters['orderId']!), s)),
      GoRoute(path: '/receipt-verify', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const ReceiptVerifyScreen(), s)),
      GoRoute(path: '/receipt-scan', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const ReceiptScannerScreen(), s)),
      GoRoute(path: '/edit-profile', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const EditProfileScreen(), s)),
      GoRoute(path: '/support', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const SupportScreen(), s)),
      GoRoute(path: '/chats', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const ChatsScreen(), s)),
      GoRoute(path: '/chats/:chatId', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(ChatConversationScreen(chatId: s.pathParameters['chatId']!), s)),

      // Раздел продавца
      GoRoute(path: '/my-products', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const MyProductsScreen(), s)),
      GoRoute(path: '/my-products/add', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const AddProductScreen(), s)),
      GoRoute(path: '/analytics', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const AnalyticsScreen(), s)),
      GoRoute(path: '/seller-orders', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const SellerOrdersScreen(), s)),
      GoRoute(
        path: '/seller-orders/:orderId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (c, s) => _smoothPage(SellerOrderDetailScreen(orderId: s.pathParameters['orderId']!), s),
      ),
      GoRoute(path: '/product-reviews', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (c, s) => _smoothPage(const ProductReviewsScreen(), s)),
    ],
  );
}
