import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_label.dart';
import '../../../models/order.dart';
import '../../../state/seller_order_provider.dart';
import '../../../state/app_settings_provider.dart';
import '../../../data/mock_data.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerOrders = context.watch<SellerOrderProvider>();
    final drafts = sellerOrders.drafts;
    final language = context.watch<AppSettingsProvider>().language;
    final isKyrgyz = language == AppLanguage.kyrgyz;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKyrgyz
              ? 'Кардарлардын буйрутмалары'
              : 'Заказы покупателей',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          32,
        ),
        children: [
          // Если заказов нет
          if (drafts.isEmpty && mockSellerOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  isKyrgyz
                      ? 'Азырынча буйрутмалар жок'
                      : 'Пока заказов нет',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ),
            ),

          // Новые заказы (добавлены продавцом вручную со страницы товара) —
          // тоже можно вести по этапам обработки.
          for (final d in drafts)
            _SellerOrderCard(
              icon: Icons.add_task_rounded,
              title:
                  '${isKyrgyz ? 'Жаңы буйрутма' : 'Новый заказ'} · ${d.quantity} шт.',
              subtitle: d.product.name,
              stage: sellerOrders.draftStageFor(d.id),
              isKyrgyz: isKyrgyz,
              onStageChanged: (stage) => sellerOrders.setDraftStage(d.id, stage),
            ),

          // Реальные заказы, созданные покупателями в этом запуске приложения.
          for (final o in sellerOrders.liveOrders)
            _SellerOrderCard(
              icon: Icons.notifications_active_outlined,
              title: '${o.buyerName} · №${o.id}',
              subtitle: '${o.summary} · ${o.total.toStringAsFixed(0)} сом',
              stage: sellerOrders.stageFor(o.id),
              isKyrgyz: isKyrgyz,
              onStageChanged: (stage) => sellerOrders.setStage(o.id, stage),
            ),

          // Демо-заказы.
          for (final o in mockSellerOrders)
            _SellerOrderCard(
              icon: Icons.person_outline,
              title: '${o.buyerName} · №${o.id}',
              subtitle: o.summary,
              stage: sellerOrders.stageFor(o.id),
              isKyrgyz: isKyrgyz,
              onStageChanged: (stage) => sellerOrders.setStage(o.id, stage),
            ),
        ],
      ),
    );
  }
}

/// Карточка заказа покупателя в разделе продавца: сверху — кто и что
/// заказал плюс текущий этап цветным бейджем, снизу — кнопки, которыми
/// продавец переключает этап. Изменение сразу видно и покупателю в его
/// «Моих заказах» (тот же провайдер, общее состояние на всё приложение).
class _SellerOrderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final SellerOrderStage stage;
  final bool isKyrgyz;
  final ValueChanged<SellerOrderStage> onStageChanged;

  const _SellerOrderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stage,
    required this.isKyrgyz,
    required this.onStageChanged,
  });

  static const _allStages = [
    SellerOrderStage.searching,
    SellerOrderStage.processing,
    SellerOrderStage.shipped,
    SellerOrderStage.delivered,
    SellerOrderStage.cancelled,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, size: 19, color: AppColors.inkSoft),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.inkFaint)),
                  ],
                ),
              ),
              StagePill(stage, isKyrgyz: isKyrgyz),
            ],
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in _allStages)
                _StageButton(
                  label: s.shortLabel(isKyrgyz),
                  selected: stage == s,
                  onTap: () => onStageChanged(s),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StageButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _StageButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : AppColors.paper2,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: selected ? scheme.primary : AppColors.line),
          boxShadow: selected ? AppColors.floatingShadow(dark: Theme.of(context).brightness == Brightness.dark, tint: scheme.primary) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.inkSoft,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
