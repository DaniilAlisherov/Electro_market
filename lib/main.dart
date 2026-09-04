import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/router/app_router.dart';
import 'state/cart_provider.dart';
import 'state/catalog_provider.dart';
import 'state/user_provider.dart';
import 'state/app_settings_provider.dart';
import 'state/seller_order_provider.dart';
import 'state/review_provider.dart';

void main() {
  final userProvider = UserProvider();
  final router = buildAppRouter(userProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SellerOrderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: ElectroMarketApp(router: router),
    ),
  );
}
