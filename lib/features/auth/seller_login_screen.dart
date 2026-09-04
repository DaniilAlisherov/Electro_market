import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/user_provider.dart';
import 'phone_auth_flow.dart';

class SellerLoginScreen extends StatelessWidget {
  const SellerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneAuthFlow(
      isSeller: true,
      title: 'Кабинет продавца',
      subtitle: 'Подтвердите номер, создайте пароль и завершите вход кодом продавца.',
      icon: Icons.storefront_outlined,
      onBack: () => context.pop(),
      onComplete: ({required phone, required password, sellerCode}) async {
        return context.read<UserProvider>().loginAsSellerVerified(
              phone,
              password,
              sellerCode ?? '',
            );
      },
    );
  }
}
