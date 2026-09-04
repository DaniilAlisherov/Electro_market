import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../state/seller_order_provider.dart';
import '../state/app_settings_provider.dart';
import '../core/theme/app_colors.dart';

class ReceiptVerifyScreen extends StatefulWidget {
  const ReceiptVerifyScreen({super.key});

  @override
  State<ReceiptVerifyScreen> createState() => _ReceiptVerifyScreenState();
}

class _ReceiptVerifyScreenState extends State<ReceiptVerifyScreen> {
  final _controller = TextEditingController();
  bool _checked = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    final receipt = context.read<SellerOrderProvider>().receiptByCode(_controller.text);
    setState(() => _checked = true);
    if (receipt != null) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKyrgyz = context.watch<AppSettingsProvider>().language == AppLanguage.kyrgyz;
    final receipt = context.watch<SellerOrderProvider>().receiptByCode(_controller.text);
    final valid = _checked && receipt != null;

    return Scaffold(
      appBar: AppBar(title: Text(isKyrgyz ? 'Чекти текшерүү' : 'Проверка чека')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_outlined, size: 36, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(isKyrgyz ? 'Чек чыныгы экенин текшерүү' : 'Проверить подлинность чека', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 7),
                Text(isKyrgyz ? 'QR-коддогу же чектеги кодду киргизиңиз.' : 'Введите код с чека или данные, полученные после сканирования QR-кода.', style: const TextStyle(fontSize: 11.5, color: AppColors.inkFaint)),
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) { if (_checked) setState(() {}); },
                  decoration: InputDecoration(
                    labelText: isKyrgyz ? 'Чектин коду' : 'Код чека',
                    hintText: '8472-A',
                    prefixIcon: const Icon(Icons.qr_code_2_rounded),
                    suffixIcon: IconButton(onPressed: _controller.clear, icon: const Icon(Icons.clear)),
                  ),
                  onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _verify,
                    icon: const Icon(Icons.search_rounded),
                    label: Text(isKyrgyz ? 'Текшерүү' : 'Проверить'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final scanned = await context.push<String>('/receipt-scan');
                      if (!mounted || scanned == null || scanned.isEmpty) return;
                      _controller.text = scanned;
                      _verify();
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: Text(isKyrgyz ? 'QR менен текшерүү' : 'Проверить по QR'),
                  ),
                ),
                if (_checked) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: valid ? AppColors.greenTint : AppColors.redTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(valid ? Icons.check_circle_outline : Icons.error_outline, color: valid ? AppColors.green : AppColors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            valid
                                ? '${isKyrgyz ? 'Чек жарактуу' : 'Чек действителен'} · №${receipt!.orderId} · ${receipt.total.toStringAsFixed(0)} сом'
                                : (isKyrgyz ? 'Мындай чек табылган жок' : 'Такой чек не найден'),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: valid ? AppColors.green : AppColors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(isKyrgyz ? 'QR-код' : 'QR-код', style: const TextStyle(fontSize: 11, color: AppColors.inkFaint)),
          const SizedBox(height: 6),
          Text(isKyrgyz ? 'QR код ошол эле текшерүү кодун камтыйт. Аны телефондун камерасы менен сканерлеп, андан кийин алынган кодду ушул жерге киргизсеңиз болот.' : 'QR содержит данные того же чека. Его можно отсканировать камерой телефона, после чего проверить полученный код здесь.', style: const TextStyle(fontSize: 10.5, color: AppColors.inkFaint)),
        ],
      ),
    );
  }
}
