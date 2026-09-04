import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/payment_card.dart';
import '../../../state/app_settings_provider.dart';
import '../../../state/user_provider.dart';
import '../../../core/theme/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  void _addCard() {
    final l = context.read<AppSettingsProvider>().language;
    final number = TextEditingController();
    final holder = TextEditingController();
    final expiry = TextEditingController();
    final cvv = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(20, 6, 20, MediaQuery.of(sheet).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(alignment: Alignment.centerLeft, child: Text(l == AppLanguage.kyrgyz ? 'Жаңы карта' : 'Новая карта', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          const SizedBox(height: 16),
          TextField(controller: number, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l == AppLanguage.kyrgyz ? 'Картанын номери' : 'Номер карты', hintText: '0000 0000 0000 0000')),
          const SizedBox(height: 10),
          TextField(controller: holder, decoration: InputDecoration(labelText: l == AppLanguage.kyrgyz ? 'Карта ээси' : 'Владелец')),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: TextField(controller: expiry, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'MM/YY'))), const SizedBox(width: 12), Expanded(child: TextField(controller: cvv, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CVV')))]),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            final digits = number.text.replaceAll(RegExp(r'\D'), '');
            final ex = expiry.text.replaceAll(RegExp(r'\D'), '');
            final month = int.tryParse(ex.length >= 2 ? ex.substring(0, 2) : '') ?? 0;
            final year = int.tryParse(ex.length >= 4 ? ex.substring(2, 4) : '') ?? -1;
            final now = DateTime.now();
            final validLength = digits.length >= 12 && digits.length <= 19;
            var sum = 0;
            var doubleDigit = false;
            for (var i = digits.length - 1; i >= 0; i--) {
              var n = int.parse(digits[i]);
              if (doubleDigit) {
                n *= 2;
                if (n > 9) n -= 9;
              }
              sum += n;
              doubleDigit = !doubleDigit;
            }
            final luhnOk = validLength && sum % 10 == 0;
            final expiryOk = month >= 1 && month <= 12 && year >= 0 &&
                (2000 + year > now.year || (2000 + year == now.year && month >= now.month));
            if (!luhnOk || !expiryOk || cvv.text.length < 3 || holder.text.trim().isEmpty) {
              ScaffoldMessenger.of(sheet).showSnackBar(
                SnackBar(content: Text(l == AppLanguage.kyrgyz
                    ? 'Картанын маалыматтарын туура толтуруңуз.'
                    : 'Проверьте номер карты, срок действия, CVV и владельца.')),
              );
              return;
            }
            final isEmpty = context.read<UserProvider>().cards.isEmpty;
            context.read<UserProvider>().addCard(PaymentCard(id: DateTime.now().millisecondsSinceEpoch.toString(), holder: holder.text.trim(), last4: digits.substring(digits.length - 4), brand: digits.startsWith('4') ? 'VISA' : 'CARD', expiryMonth: int.tryParse(ex.substring(0,2)) ?? 1, expiryYear: 2000 + (int.tryParse(ex.substring(2,4)) ?? 30), isDefault: isEmpty));
            Navigator.of(sheet).pop();
            setState(() {});
          }, child: Text(l == AppLanguage.kyrgyz ? 'Картаны сактоо' : 'Сохранить карту'))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppSettingsProvider>().language;
    final cards = context.watch<UserProvider>().cards;
    return Scaffold(
      appBar: AppBar(title: Text(l == AppLanguage.kyrgyz ? 'Төлөм ыкмалары' : 'Способы оплаты')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 32), children: [
        for (final card in cards) Padding(padding: const EdgeInsets.only(bottom: 12), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)), child: Row(children: [
          Container(width: 48, height: 34, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(9)), alignment: Alignment.center, child: Text(card.brand, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('•••• ${card.last4}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), Text(card.holder, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant))])),
          PopupMenuButton<String>(onSelected: (v) { if (v == 'default') context.read<UserProvider>().setDefaultCard(card.id); if (v == 'remove') context.read<UserProvider>().removeCard(card.id); }, itemBuilder: (c) => [PopupMenuItem(value: 'default', child: Text(l == AppLanguage.kyrgyz ? 'Негизги кылуу' : 'Сделать основной')), PopupMenuItem(value: 'remove', child: Text(l == AppLanguage.kyrgyz ? 'Өчүрүү' : 'Удалить'))]),
        ]))),
        OutlinedButton.icon(onPressed: _addCard, icon: const Icon(Icons.add_card_rounded), label: Text(l == AppLanguage.kyrgyz ? 'Карта кошуу' : 'Добавить карту')),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Theme.of(context).colorScheme.primary.withValues(alpha: .06)), child: Row(children: [Icon(Icons.lock_outline_rounded, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 10), Expanded(child: Text(l == AppLanguage.kyrgyz ? 'Карта маалыматтары демонстрациялык режимде түзмөктө гана сакталат.' : 'Данные карты в демонстрационном режиме хранятся только на устройстве.', style: TextStyle(fontSize: 11, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant)))])),
      ]),
    );
  }
}
