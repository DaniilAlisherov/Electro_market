import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_data.dart';
import '../../../models/order.dart';
import '../../../state/seller_order_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String period = '7 дней';

  List<BuyerOrder> _allOrders(SellerOrderProvider provider) {
    final byId = <String, BuyerOrder>{
      for (final order in mockSellerOrders) order.id: order,
    };
    // Live order replaces a demo order with the same id, if that ever happens.
    for (final order in provider.liveOrders) byId[order.id] = order;
    return byId.values.toList();
  }

  List<BuyerOrder> _periodOrders(List<BuyerOrder> orders) {
    if (period == 'Все время') return orders;
    final days = period == '7 дней' ? 7 : period == '30 дней' ? 30 : 90;
    final now = DateTime.now();
    final from = now.subtract(Duration(days: days));
    return orders.where((o) => o.createdAt == null || !o.createdAt!.isBefore(from)).toList();
  }

  bool _isCancelled(SellerOrderProvider provider, BuyerOrder order) =>
      provider.stageFor(order.id) == SellerOrderStage.cancelled;

  bool _isDelivered(SellerOrderProvider provider, BuyerOrder order) =>
      provider.stageFor(order.id) == SellerOrderStage.delivered;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellerOrderProvider>();
    final orders = _periodOrders(_allOrders(provider));
    final activeOrders = orders.where((o) => !_isCancelled(provider, o)).toList();
    final completed = orders.where((o) => _isDelivered(provider, o)).toList();
    final revenue = activeOrders.fold<double>(0, (sum, o) => sum + o.total);
    final average = activeOrders.isEmpty ? 0.0 : revenue / activeOrders.length;
    final sold = activeOrders.fold<int>(0, (sum, o) => sum + o.itemCount);
    final chart = _chartData(orders);

    return Scaffold(
      appBar: AppBar(title: const Text('Продажи и аналитика')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ПРОФЕССИОНАЛЬНАЯ АНАЛИТИКА', style: TextStyle(fontSize: 10.5, letterSpacing: .8, color: AppColors.inkFaint)),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: period,
                  isDense: true,
                  borderRadius: BorderRadius.circular(12),
                  items: const ['7 дней', '30 дней', '90 дней', 'Все время']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v, style: TextStyle(fontSize: 11))))
                      .toList(),
                  onChanged: (v) => setState(() => period = v ?? period),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            _StatCard(num: '${revenue.toStringAsFixed(0)}', label: 'выручка, сом'),
            _StatCard(num: '${activeOrders.length}', label: 'заказов'),
            _StatCard(num: '$sold', label: 'товаров продано', last: true),
          ]),
          _ChartCard(data: chart),
          const SizedBox(height: 18),
          _SectionTitle('Ключевые показатели'),
          _MetricCard(children: [
            _metric('Средний чек', '${average.toStringAsFixed(0)} сом'),
            _metric('Доставлено', '${completed.length} заказов'),
            _metric('Активные заказы', '${orders.where((o) => !_isCancelled(provider, o) && !_isDelivered(provider, o)).length}'),
            _metric('Отменено', '${orders.where((o) => _isCancelled(provider, o)).length}'),
            _metric('Конверсия в доставку', activeOrders.isEmpty ? '—' : '${(completed.length / activeOrders.length * 100).toStringAsFixed(0)}%'),
          ]),
          const SizedBox(height: 18),
          _SectionTitle('Что показывает аналитика'),
          _InfoRow(
            icon: Icons.trending_up_rounded,
            title: 'Выручка',
            value: '${revenue.toStringAsFixed(0)} сом',
            text: 'Сумма всех неотменённых заказов за выбранный период.',
            onTap: () => _showDetails(context, 'Выручка', 'За период «$period» продавец получил ${revenue.toStringAsFixed(0)} сом по ${activeOrders.length} неотменённым заказам.'),
          ),
          _InfoRow(
            icon: Icons.shopping_bag_outlined,
            title: 'Заказы',
            value: '${activeOrders.length}',
            text: 'Количество заказов и их текущие этапы.',
            onTap: () => _showOrders(context, provider, orders),
          ),
          _InfoRow(
            icon: Icons.receipt_long_outlined,
            title: 'Средний чек',
            value: '${average.toStringAsFixed(0)} сом',
            text: 'Выручка ÷ количество неотменённых заказов.',
            onTap: () => _showDetails(context, 'Средний чек', activeOrders.isEmpty ? 'Пока нет заказов за выбранный период.' : 'Средняя сумма одного неотменённого заказа: ${average.toStringAsFixed(0)} сом.'),
          ),
          _InfoRow(
            icon: Icons.inventory_2_outlined,
            title: 'Товары продано',
            value: '$sold шт.',
            text: 'Количество единиц товара во всех неотменённых заказах.',
            onTap: () => _showDetails(context, 'Товары продано', 'За выбранный период продано $sold товарных единиц.'),
          ),
          const SizedBox(height: 10),
          Text('Показатели обновляются сразу после оформления заказа или изменения его этапа продавцом.', style: TextStyle(fontSize: 10.5, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  List<double> _chartData(List<BuyerOrder> orders) {
    final result = List<double>.filled(7, 0);
    final now = DateTime.now();
    for (final order in orders) {
      if (_isCancelled(context.read<SellerOrderProvider>(), order)) continue;
      final date = order.createdAt ?? now;
      final diff = now.difference(date).inDays;
      if (diff >= 0 && diff < 7) {
        result[6 - diff] += order.total;
      }
    }
    return result;
  }

  void _showDetails(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Закрыть'))],
      ),
    );
  }

  void _showOrders(BuildContext context, SellerOrderProvider provider, List<BuyerOrder> orders) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Text('Заказы за период', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (orders.isEmpty) const Text('Заказов пока нет.'),
            for (final order in orders)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text('№${order.id} · ${order.total.toStringAsFixed(0)} сом'),
                subtitle: Text('${order.buyerName ?? 'Покупатель'} · ${provider.stageFor(order.id).shortLabel(false)}'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 12, color: AppColors.inkFaint)),
      Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _ChartCard extends StatelessWidget {
  final List<double> data;
  const _ChartCard({required this.data});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Продажи за 7 дней', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        Text('сом', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
      const SizedBox(height: 12),
      SizedBox(height: 150, child: CustomPaint(painter: _SalesChartPainter(data: data, lineColor: Theme.of(context).colorScheme.primary))),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [Text('6д', style: TextStyle(fontSize: 9)), Text('5д', style: TextStyle(fontSize: 9)), Text('4д', style: TextStyle(fontSize: 9)), Text('3д', style: TextStyle(fontSize: 9)), Text('2д', style: TextStyle(fontSize: 9)), Text('вчера', style: TextStyle(fontSize: 9)), Text('сегодня', style: TextStyle(fontSize: 9))]),
    ]),
  );
}

class _SalesChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  _SalesChartPainter({required this.data, required this.lineColor});
  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = math.max(1, data.reduce(math.max));
    final grid = Paint()..color = lineColor.withValues(alpha: .10)..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = i * size.height / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - (data[i] / maxValue) * (size.height - 12) - 6;
      points.add(Offset(x, y));
    }
    final path = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) path.lineTo(p.dx, p.dy);
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = lineColor.withValues(alpha: .08));
    final line = Paint()..color = lineColor..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final curve = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final cur = points[i];
      final mid = (prev.dx + cur.dx) / 2;
      curve.cubicTo(mid, prev.dy, mid, cur.dy, cur.dx, cur.dy);
    }
    canvas.drawPath(curve, line);
    final dot = Paint()..color = lineColor;
    for (final p in points) canvas.drawCircle(p, 3.5, dot);
  }
  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) => oldDelegate.data != data || oldDelegate.lineColor != lineColor;
}

class _MetricCard extends StatelessWidget {
  final List<Widget> children;
  const _MetricCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)), child: Column(children: children));
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 3, bottom: 8), child: Text(text.toUpperCase(), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: .7, color: Theme.of(context).colorScheme.onSurfaceVariant)));
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String text;
  final VoidCallback onTap;
  const _InfoRow({required this.icon, required this.title, required this.value, required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(text, style: TextStyle(fontSize: 10.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ])),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Icon(Icons.chevron_right_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ]),
          ]),
        ),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String num; final String label; final bool last;
  const _StatCard({required this.num, required this.label, this.last = false});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(margin: EdgeInsets.only(right: last ? 0 : 8, bottom: 18), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)), child: Column(children: [Text(num, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurfaceVariant))])));
}
