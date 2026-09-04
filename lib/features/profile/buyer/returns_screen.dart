import 'package:flutter/material.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/price_text.dart';
import '../../../data/mock_data.dart';

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История и возвраты')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          for (final r in mockReturns)
            InfoListTile(
              icon: Icons.replay_rounded,
              title: 'Возврат по заказу №${r.orderId}',
              subtitle: r.reason,
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusPill(r.status),
                  const SizedBox(height: 4),
                  PriceText(r.amount, size: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
