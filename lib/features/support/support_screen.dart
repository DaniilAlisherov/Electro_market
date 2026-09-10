import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _messageCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (_messageCtrl.text.trim().isEmpty) return;
    setState(() => _sent = true);
    _messageCtrl.clear();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _sent = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Техподдержка')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const Text('Свяжитесь с нами', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Отвечаем каждый день с 9:00 до 21:00', style: TextStyle(fontSize: 12, color: AppColors.inkFaint)),
          const SizedBox(height: 16),
          _ContactRow(icon: Icons.call_outlined, title: 'Телефон', value: '+996 700 000 000'),
          _ContactRow(icon: Icons.mail_outline, title: 'Почта', value: 'support@electromarket.kg'),
          _ContactRow(icon: Icons.telegram, title: 'Telegram', value: '@electromarket_support'),

          const SizedBox(height: 26),
          const Text('Написать в поддержку', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Опишите вопрос — ответим на указанный в профиле телефон', style: TextStyle(fontSize: 12, color: AppColors.inkFaint)),
          const SizedBox(height: 14),
          TextField(
            controller: _messageCtrl,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'Например: не приходит подтверждение заказа №10482'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _send,
              icon: const Icon(Icons.send_outlined, size: 16),
              label: const Text('Отправить'),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _sent
                ? Padding(
                    key: const ValueKey('sent'),
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.greenTint, borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: AppColors.green),
                          SizedBox(width: 8),
                          Expanded(child: Text('Сообщение отправлено, мы ответим в ближайшее время', style: TextStyle(fontSize: 12, color: AppColors.green))),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),

          const SizedBox(height: 26),
          const Text('Частые вопросы', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          const _FaqTile(question: 'Как отследить заказ?', answer: 'Статус заказа виден в разделе «Мои заказы» в профиле.'),
          const _FaqTile(question: 'Можно ли вернуть товар?', answer: 'Да, оформите возврат в разделе «История и возвраты» в течение 14 дней с момента доставки.'),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _ContactRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 17, color: AppColors.inkSoft),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10.5, color: AppColors.inkFaint)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _open = !_open),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    Expanded(child: Text(widget.question, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      turns: _open ? 0.5 : 0,
                      child: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.inkFaint),
                    ),
                  ],
                ),
              ),
            ),
            if (_open)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Text(widget.answer, style: const TextStyle(fontSize: 12, color: AppColors.inkFaint, height: 1.4)),
              ),
          ],
        ),
      ),
    );
  }
}
