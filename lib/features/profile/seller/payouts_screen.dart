import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/price_text.dart';
import '../../../core/widgets/section_label.dart';

class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  static const _history = <_PayoutEntry>[
    _PayoutEntry('ЭЛСОМ', '04.09.2026', 42000),
    _PayoutEntry('MBank', '28.08.2026', 28240),
    _PayoutEntry('Бакай Банк', '15.08.2026', 16000),
    _PayoutEntry('ЭЛСОМ', '02.08.2026', 10000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выплаты')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B2027), Color(0xFF2A313A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow(
                dark: Theme.of(context).brightness == Brightness.dark,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ДОСТУПНО К ВЫПЛАТЕ',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: AppColors.copperLight,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '86 240 сом',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.ink,
                  ),
                  child: const Text('Запросить выплату'),
                ),
              ],
            ),
          ),
          const SectionLabel('История'),
          for (final p in _history)
            InfoListTile(
              icon: Icons.account_balance_wallet_outlined,
              title: p.destination,
              subtitle: p.date,
              trailing: PriceText(
                p.amount,
                size: 12,
                color: AppColors.green,
              ),
            ),
        ],
      ),
    );
  }
}

class _PayoutEntry {
  final String destination;
  final String date;
  final double amount;
  const _PayoutEntry(this.destination, this.date, this.amount);
}
