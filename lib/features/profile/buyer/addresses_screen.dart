import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../state/user_provider.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final address = context.watch<UserProvider>().address;

    return Scaffold(
      appBar: AppBar(title: const Text('Адрес доставки')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: address == null
            ? _EmptyState(onAdd: () => context.push('/addresses/edit'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line), boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark)),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(11)),
                          child: const Icon(Icons.location_on_outlined, size: 19, color: AppColors.inkSoft),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(address.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(address.details, style: const TextStyle(fontSize: 11, color: AppColors.inkFaint)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/addresses/edit'),
                          icon: const Icon(Icons.edit_outlined, size: 15),
                          label: const Text('Изменить'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDelete(context),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.redTint)),
                          icon: const Icon(Icons.delete_outline, size: 15),
                          label: const Text('Удалить'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить адрес?'),
        content: const Text('Вы сможете добавить новый адрес в любой момент.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<UserProvider>().clearAddress();
            },
            child: const Text('Удалить', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.location_on_outlined, size: 40, color: AppColors.inkFaint),
        const SizedBox(height: 12),
        const Text('Адрес доставки ещё не добавлен', textAlign: TextAlign.center, style: TextStyle(color: AppColors.inkFaint, fontSize: 13)),
        const SizedBox(height: 18),
        ElevatedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add, size: 16), label: const Text('Добавить адрес')),
      ],
    );
  }
}
