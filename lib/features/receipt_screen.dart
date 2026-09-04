import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../state/seller_order_provider.dart';
import '../state/app_settings_provider.dart';
import '../core/theme/app_colors.dart';
import '../models/order.dart';

class ReceiptScreen extends StatelessWidget {
  final String orderId;

  const ReceiptScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final receipt = context.watch<SellerOrderProvider>().receiptFor(orderId);
    final isKyrgyz = context.watch<AppSettingsProvider>().language == AppLanguage.kyrgyz;

    if (receipt == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isKyrgyz ? 'Чек' : 'Чек')),
        body: Center(child: Text(isKyrgyz ? 'Чек табылган жок' : 'Чек не найден')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isKyrgyz ? 'Электрондук чек' : 'Электронный чек'),
        actions: [
          IconButton(
            tooltip: isKyrgyz ? 'Текшерүү' : 'Проверить чек',
            onPressed: () => context.push('/receipt-verify'),
            icon: const Icon(Icons.verified_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
        child: _ReceiptCard(receipt: receipt, isKyrgyz: isKyrgyz),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final OrderReceipt receipt;
  final bool isKyrgyz;

  const _ReceiptCard({required this.receipt, required this.isKyrgyz});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow(dark: dark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '__________________________________',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'monospace', color: AppColors.inkFaint),
          ),
          const SizedBox(height: 8),
          Text(
            'ЭЛЕКТРО - МАРКЕТ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          const Text(
            '__________________________________',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'monospace', color: AppColors.inkFaint),
          ),
          const SizedBox(height: 16),
          for (final item in receipt.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} ×${item.quantity}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                  Text(
                    '${item.total.toStringAsFixed(0)} сом',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          const Divider(height: 24),
          _ReceiptRow(label: isKyrgyz ? 'Товарлар' : 'Товары', value: receipt.subtotal),
          _ReceiptRow(label: isKyrgyz ? 'Жеткирүү' : 'Доставка', value: receipt.delivery),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: receipt.qrData,
                  size: 92,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isKyrgyz ? 'Чектин коду:' : 'Код чека:', style: const TextStyle(fontSize: 11, color: AppColors.inkFaint)),
                    const SizedBox(height: 4),
                    Text('#${receipt.code}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(isKyrgyz ? 'QR-кодду сканерлеп же кодду киргизип текшериңиз.' : 'Проверьте чек по QR-коду или введите код вручную.', style: const TextStyle(fontSize: 10.5, color: AppColors.inkFaint)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isKyrgyz ? 'Баары:' : 'Итого:', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              Text('${receipt.total.toStringAsFixed(0)} сом', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${isKyrgyz ? 'Буйрутма' : 'Заказ'} №${receipt.orderId} · ${receipt.createdAt.day.toString().padLeft(2, '0')}.${receipt.createdAt.month.toString().padLeft(2, '0')}.${receipt.createdAt.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.inkFaint),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final double value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.inkFaint)),
          Text('${value.toStringAsFixed(0)} сом', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
