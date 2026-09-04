import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/order.dart';
import '../../../state/user_provider.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _detailsCtrl;

  @override
  void initState() {
    super.initState();
    final existing = context.read<UserProvider>().address;
    _labelCtrl = TextEditingController(text: existing?.label ?? 'Дом');
    _detailsCtrl = TextEditingController(text: existing?.details ?? '');
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<UserProvider>().setAddress(Address(label: _labelCtrl.text.trim(), details: _detailsCtrl.text.trim()));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = context.read<UserProvider>().address != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Изменить адрес' : 'Новый адрес')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text('НАЗВАНИЕ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: .3, color: Color(0xFF8B9096))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(hintText: 'Дом, Офис, Склад...'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Укажите название' : null,
            ),
            const SizedBox(height: 16),
            const Text('АДРЕС', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: .3, color: Color(0xFF8B9096))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _detailsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Город Манас', hintText: 'Улица, дом, квартира'),
              validator: (v) { final value = v?.trim() ?? ''; if (value.isEmpty) return 'Укажите адрес'; if (!value.toLowerCase().contains('манас')) return 'Доставка доступна только в городе Манас'; return null; },
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
            ),
          ],
        ),
      ),
    );
  }
}
