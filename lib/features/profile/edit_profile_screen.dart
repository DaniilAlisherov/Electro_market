import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../state/app_settings_provider.dart';
import '../../state/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl, _phoneCtrl, _emailCtrl, _cityCtrl, _bioCtrl;
  Uint8List? _avatarBytes;
  bool _pickingPhoto = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameCtrl = TextEditingController(text: user.name);
    _phoneCtrl = TextEditingController(text: user.phone);
    _emailCtrl = TextEditingController(text: user.email);
    _cityCtrl = TextEditingController(text: user.city);
    _bioCtrl = TextEditingController(text: user.bio);
    _avatarBytes = user.avatarBytes;
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _cityCtrl, _bioCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_pickingPhoto) return;
    setState(() => _pickingPhoto = true);
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 800);
      if (file == null) { if (mounted) setState(() => _pickingPhoto = false); return; }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() { _avatarBytes = bytes; _pickingPhoto = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _pickingPhoto = false);
      final l = context.read<AppSettingsProvider>().language;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l == AppLanguage.kyrgyz ? 'Сүрөттөргө кирүүгө уруксатты текшериңиз' : 'Проверьте разрешение на доступ к фото')));
    }
  }

  void _save() {
    final l = context.read<AppSettingsProvider>().language;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<UserProvider>().updateProfile(
      name: _nameCtrl.text, phone: _phoneCtrl.text, email: _emailCtrl.text,
      city: _cityCtrl.text, bio: _bioCtrl.text, avatarBytes: _avatarBytes,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.profileUpdated(l)), behavior: SnackBarBehavior.floating));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<UserProvider>().role;
    final l = context.watch<AppSettingsProvider>().language;
    final isSeller = role == UserRole.seller;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editProfile(l))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220), width: 92, height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _avatarBytes == null ? LinearGradient(colors: [scheme.primary.withValues(alpha: .55), scheme.primary]) : null,
                      image: _avatarBytes != null ? DecorationImage(image: MemoryImage(_avatarBytes!), fit: BoxFit.cover) : null,
                      boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: .16), blurRadius: 24, offset: const Offset(0, 10))],
                    ),
                    alignment: Alignment.center,
                    child: _avatarBytes == null ? Text(_nameCtrl.text.trim().isEmpty ? '?' : _nameCtrl.text.trim().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)) : null,
                  ),
                  Positioned(right: 0, bottom: 0, child: Container(
                    width: 31, height: 31,
                    decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle, border: Border.all(color: scheme.surface, width: 2)),
                    child: _pickingPhoto ? const Padding(padding: EdgeInsets.all(7), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: TextButton(onPressed: _pickingPhoto ? null : _pickAvatar, child: Text(AppStrings.editPhoto(l), style: const TextStyle(fontSize: 12.5)))),
            const SizedBox(height: 18),
            _FieldLabel(text: isSeller ? AppStrings.storeName(l) : AppStrings.name(l)),
            TextFormField(controller: _nameCtrl, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: AppStrings.nameHint(l)), validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.required(l) : null),
            const SizedBox(height: 15),
            _FieldLabel(text: AppStrings.phone(l)),
            TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+996 700 123 456'), validator: (v) {
              final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
              return digits.length < 9 ? AppStrings.invalidPhone(l) : null;
            }),
            const SizedBox(height: 15),
            _FieldLabel(text: AppStrings.email(l)),
            TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'name@example.com'), validator: (v) {
              if ((v ?? '').trim().isEmpty) return null;
              return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim()) ? null : AppStrings.invalidEmail(l);
            }),
            const SizedBox(height: 15),
            _FieldLabel(text: AppStrings.city(l)),
            TextFormField(controller: _cityCtrl, decoration: InputDecoration(hintText: AppStrings.cityHint(l))),
            const SizedBox(height: 15),
            _FieldLabel(text: AppStrings.aboutMe(l)),
            TextFormField(controller: _bioCtrl, maxLines: 4, maxLength: 180, decoration: InputDecoration(hintText: AppStrings.bioHint(l), alignLabelWithHint: true)),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.check_rounded, size: 17), label: Text(AppStrings.save(l)))),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: .35, color: Theme.of(context).colorScheme.onSurfaceVariant)));
}
