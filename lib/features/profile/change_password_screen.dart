import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/app_settings_provider.dart';
import '../../state/user_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _code = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();

  bool _verified = false;
  bool _o1 = true;
  bool _o2 = true;

  @override
  void dispose() {
    _code.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _verify() {
    final user = context.read<UserProvider>();

    if (user.verifySmsCode(_code.text.trim())) {
      setState(() => _verified = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Неверный SMS-код'),
        ),
      );
    }
  }

  void _save() {
    final settings = context.read<AppSettingsProvider>();
    final user = context.read<UserProvider>();
    final l = settings.language;

    final err = user.changePassword(
      _new.text.trim(),
      _repeat.text.trim(),
    );

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l == AppLanguage.kyrgyz
              ? 'Сыр сөз өзгөртүлдү'
              : 'Пароль изменён',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppSettingsProvider>().language;
    final user = context.watch<UserProvider>();
    final phone = user.phone;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l == AppLanguage.kyrgyz ? 'Сыр сөз' : 'Пароль',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          Text(
            l == AppLanguage.kyrgyz
                ? 'Коопсуздук үчүн SMS-кодду киргизиңиз'
                : 'Для безопасности сначала подтвердите номер по SMS',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            phone,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l == AppLanguage.kyrgyz
                  ? 'SMS-код'
                  : 'SMS-код',
              suffixIcon: IconButton(
                onPressed: _verify,
                icon: const Icon(Icons.verified_outlined),
              ),
            ),
          ),

          if (_verified) ...[
            const SizedBox(height: 18),

            TextField(
              controller: _new,
              obscureText: _o1,
              decoration: InputDecoration(
                labelText: l == AppLanguage.kyrgyz
                    ? 'Жаңы сыр сөз'
                    : 'Новый пароль',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _o1 = !_o1);
                  },
                  icon: Icon(
                    _o1
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _repeat,
              obscureText: _o2,
              decoration: InputDecoration(
                labelText: l == AppLanguage.kyrgyz
                    ? 'Сыр сөздү кайталаңыз'
                    : 'Повторите пароль',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _o2 = !_o2);
                  },
                  icon: Icon(
                    _o2
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  l == AppLanguage.kyrgyz
                      ? 'Сактоо'
                      : 'Сохранить',
                ),
              ),
            ),
          ] else
            const SizedBox(height: 12),

          if (!_verified)
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                l == AppLanguage.kyrgyz
                    ? 'Демо-код: 123456'
                    : 'Для демонстрации: код 123456',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}