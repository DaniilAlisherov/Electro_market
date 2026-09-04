import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/user_provider.dart';
import 'phone_auth_flow.dart';

class BuyerLoginScreen extends StatelessWidget {
  const BuyerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneAuthFlow(
      isSeller: false,
      title: 'Добро пожаловать',
      subtitle: 'Создайте безопасный вход для покупателя — без лишних шагов.',
      icon: Icons.person_outline_rounded,
      onBack: () => context.pop(),
      onComplete: ({required phone, required password, sellerCode}) async {
        return context.read<UserProvider>().loginAsBuyerVerified(
              phone,
              password,
            );
      },
    );
  }
}
