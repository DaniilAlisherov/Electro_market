import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/product.dart';
import '../../../state/catalog_provider.dart';

class _SpecRow {
  final TextEditingController key = TextEditingController();
  final TextEditingController value = TextEditingController();
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _categoryId;
  bool _categoryTouched = false;

  final List<Uint8List> _images = [];
  bool _pickingImages = false;

  final List<_SpecRow> _specRows = [_SpecRow()];
  final _picker = ImagePicker();

  /// Загрузка фото обёрнута так, чтобы НИКАКАЯ ошибка пикера (нет
  /// разрешения, платформа не поддерживает выбор нескольких файлов,
  /// повреждённый файл и т.д.) не роняла экран — в худшем случае
  /// пользователь просто увидит понятное сообщение и сможет попробовать ещё раз.
  Future<void> _pickImages() async {
    if (_pickingImages) return;
    final remaining = 8 - _images.length;
    if (remaining <= 0) {
      _showMessage('Можно добавить не больше 8 фото');
      return;
    }

    setState(() => _pickingImages = true);
    try {
      List<XFile> picked = [];
      try {
        picked = await _picker.pickMultiImage(limit: remaining, imageQuality: 85);
      } catch (_) {
        // Некоторые платформы/версии плагина не поддерживают выбор
        // нескольких файлов сразу — пробуем выбрать одно фото как запасной вариант.
        final single = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
        if (single != null) picked = [single];
      }

      if (picked.isEmpty) {
        if (mounted) setState(() => _pickingImages = false);
        return;
      }

      final newBytes = <Uint8List>[];
      for (final file in picked.take(remaining)) {
        try {
          final bytes = await file.readAsBytes();
          if (bytes.isNotEmpty) newBytes.add(bytes);
        } catch (_) {
          // Пропускаем файл, который не удалось прочитать, не прерывая остальные.
        }
      }

      if (!mounted) return;
      if (newBytes.isEmpty) {
        _showMessage('Не удалось загрузить фото. Попробуйте другой файл');
      } else {
        setState(() => _images.addAll(newBytes));
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Галерея недоступна на этом устройстве. Проверьте разрешение на доступ к фото в настройках');
      }
    } finally {
      if (mounted) setState(() => _pickingImages = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  void _addSpecRow() => setState(() => _specRows.add(_SpecRow()));

  void _removeSpecRow(int index) {
    if (_specRows.length <= 1) return;
    final row = _specRows.removeAt(index);
    row.key.dispose();
    row.value.dispose();
    setState(() {});
  }

  @override
  void dispose() {
    for (final row in _specRows) {
      row.key.dispose();
      row.value.dispose();
    }
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _categoryTouched = true);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _categoryId == null) return;

    final specs = _specRows
        .where((r) => r.key.text.trim().isNotEmpty && r.value.text.trim().isNotEmpty)
        .map((r) => ProductSpec(r.key.text.trim(), r.value.text.trim()))
        .toList();

    final category = context.read<CatalogProvider>().categoryById(_categoryId!)!;

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _typeCtrl.text.trim().isEmpty ? _nameCtrl.text.trim() : '${_nameCtrl.text.trim()} · ${_typeCtrl.text.trim()}',
      categoryId: _categoryId!,
      type: _typeCtrl.text.trim().isEmpty ? null : _typeCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim().replaceAll(',', '.')),
      stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
      specs: specs,
      description: _descCtrl.text.trim(),
      sellerId: CatalogProvider.currentSellerId,
      sellerName: CatalogProvider.currentSellerName,
      imageBytes: _images.isNotEmpty ? _images.first : null,
      fallbackIcon: category.icon,
    );

    context.read<CatalogProvider>().addProduct(product);
    _showMessage('Товар опубликован и виден покупателям');

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CatalogProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Новый товар')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            const _Label('Фотографии'),
            _ImagesRow(images: _images, loading: _pickingImages, onAdd: _pickImages, onRemove: (i) => setState(() => _images.removeAt(i))),
            const SizedBox(height: 4),
            const Text('До 8 фото. Первое фото — главное на карточке товара.', style: TextStyle(fontSize: 10.5, color: AppColors.inkFaint)),
            const SizedBox(height: 18),

            const _Label('Название товара'),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'Например: Автомат C25 1П Voltrix Pro'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Укажите название товара' : null,
            ),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Категория'),
                      DropdownButtonFormField<String>(
                        value: _categoryId,
                        items: [for (final c in categories) DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))],
                        onChanged: (v) => setState(() {
                          _categoryId = v;
                          _categoryTouched = true;
                        }),
                        decoration: InputDecoration(
                          hintText: 'Выберите',
                          errorText: (_categoryId == null && _categoryTouched) ? 'Выберите категорию' : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Тип / серия'),
                      TextFormField(controller: _typeCtrl, decoration: const InputDecoration(hintText: 'Basic, Pro...')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Цена, сом'),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: '0'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Укажите цену';
                          final value = double.tryParse(v.trim().replaceAll(',', '.'));
                          if (value == null) return 'Неверный формат';
                          if (value <= 0) return 'Цена должна быть больше 0';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Остаток, шт'),
                      TextFormField(
                        controller: _stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '0'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Укажите остаток';
                          final value = int.tryParse(v.trim());
                          if (value == null || value < 0) return 'Неверный остаток';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            const _Label('Технические характеристики'),
            for (int i = 0; i < _specRows.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: TextFormField(controller: _specRows[i].key, decoration: const InputDecoration(hintText: 'Параметр, напр. Ток'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: _specRows[i].value, decoration: const InputDecoration(hintText: 'Значение, напр. 16А'))),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(9)),
                      child: IconButton(
                        onPressed: _specRows.length > 1 ? () => _removeSpecRow(i) : null,
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: _addSpecRow,
              icon: const Icon(Icons.add, size: 15, color: AppColors.copperDark),
              label: const Text('Добавить характеристику', style: TextStyle(color: AppColors.copperDark, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            const SizedBox(height: 10),

            const _Label('Описание'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Особенности товара, комплектация, условия применения...'),
            ),
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check, size: 17),
                label: const Text('Опубликовать товар'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.inkFaint, letterSpacing: .3)),
    );
  }
}

class _ImagesRow extends StatelessWidget {
  final List<Uint8List> images;
  final bool loading;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _ImagesRow({required this.images, required this.loading, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (int i = 0; i < images.length; i++)
          Stack(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.softShadow(dark: Theme.of(context).brightness == Brightness.dark),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(images[i], width: 74, height: 74, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 3,
                right: 3,
                child: GestureDetector(
                  onTap: () => onRemove(i),
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .65), shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        if (images.length < 8)
          GestureDetector(
            onTap: loading ? null : onAdd,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.paper2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line, width: 1.4),
                boxShadow: AppColors.softShadow(dark: Theme.of(context).brightness == Brightness.dark),
              ),
              child: loading
                  ? const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add, color: AppColors.inkFaint),
            ),
          ),
      ],
    );
  }
}
