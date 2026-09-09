import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_role.dart';
import '../../state/catalog_provider.dart';
import '../../state/user_provider.dart';
import '../../state/app_settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final catalog = context.watch<CatalogProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final l = settings.language;
    final language = l;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/edit-profile'),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: user.avatarBytes == null ? const LinearGradient(colors: [AppColors.copperLight, AppColors.copper]) : null,
                    image: user.avatarBytes != null ? DecorationImage(image: MemoryImage(user.avatarBytes!), fit: BoxFit.cover) : null,
                    boxShadow: AppColors.floatingShadow(dark: Theme.of(context).brightness == Brightness.dark, tint: AppColors.copper),
                  ),
                  alignment: Alignment.center,
                  child: user.avatarBytes == null
                      ? Text(user.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18))
                      : null,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: scheme.onSurface)),
                    if (user.phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(user.phone, style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: scheme.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        user.role == UserRole.seller ? AppStrings.sellerTag(l) : user.role == UserRole.buyer ? AppStrings.buyerTag(l) : '',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: scheme.primary, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/edit-profile'),
                icon: Icon(Icons.edit_outlined, size: 18, color: scheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _MenuRow(icon: Icons.person_outline, label: AppStrings.editProfile(language), onTap: () => context.push('/edit-profile')),
          const SizedBox(height: 10),
          _MenuRow(icon: Icons.settings_outlined, label: AppStrings.settings(language), onTap: () => context.push('/settings')),
          const SizedBox(height: 18),
          if (user.role == UserRole.buyer) ...[
            Row(children: [
              _StatCard(num: '12', label: l == AppLanguage.kyrgyz ? 'буйрутмалар' : 'заказов'),
              _StatCard(num: '3', label: l == AppLanguage.kyrgyz ? 'жолдо' : 'в пути'),
              _StatCard(num: user.address != null ? '1' : '0', label: l == AppLanguage.kyrgyz ? 'дарек' : 'адрес'),
            ]),
            const SizedBox(height: 8),
            _MenuRow(icon: Icons.receipt_long_outlined, label: AppStrings.orders(language), onTap: () => context.push('/orders')),
            _MenuRow(icon: Icons.favorite_border, label: AppStrings.favorites(language), onTap: () => context.push('/favorites')),
            _MenuRow(icon: Icons.location_on_outlined, label: AppStrings.addresses(language), onTap: () => context.push('/addresses')),
            _MenuRow(icon: Icons.history_rounded, label: AppStrings.returns(language), onTap: () => context.push('/returns')),
            _MenuRow(icon: Icons.chat_bubble_outline_rounded, label: AppStrings.chats(language), onTap: () => context.push('/chats')),
          ] else if (user.role == UserRole.seller) ...[
            Row(children: [
              _StatCard(num: '${catalog.myProducts.length}', label: l == AppLanguage.kyrgyz ? 'товар' : 'товаров'),
              _StatCard(num: '214', label: l == AppLanguage.kyrgyz ? 'сатуу' : 'продаж'),
              _StatCard(num: '4.8', label: l == AppLanguage.kyrgyz ? 'рейтинг' : 'рейтинг'),
            ]),
            const SizedBox(height: 8),
            _MenuRow(icon: Icons.inventory_2_outlined, label: AppStrings.myProducts(language), onTap: () => context.push('/my-products')),
            _MenuRow(icon: Icons.insights_outlined, label: AppStrings.analytics(language), onTap: () => context.push('/analytics')),
            _MenuRow(icon: Icons.bolt_outlined, label: AppStrings.productReviews(language), onTap: () => context.push('/product-reviews')),
            _MenuRow(icon: Icons.chat_bubble_outline_rounded, label: AppStrings.chats(language), onTap: () => context.push('/chats')),
          ],
          const SizedBox(height: 12),
          _MenuRow(icon: Icons.support_agent_outlined, label: AppStrings.support(language), onTap: () => context.push('/support')),
          _MenuRow(
            icon: Icons.logout_rounded,
            label: AppStrings.logout(language),
            danger: true,
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final l = context.read<AppSettingsProvider>().language;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l == AppLanguage.kyrgyz ? 'Аккаунттан чыгасызбы?' : 'Выйти из аккаунта?'),
        content: Text(l == AppLanguage.kyrgyz ? 'Телефон номери же жашыруун код менен кайра кире аласыз.' : 'Вы сможете снова войти по номеру телефона или секретному коду.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l == AppLanguage.kyrgyz ? 'Жокко чыгаруу' : 'Отмена')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<UserProvider>().logout();
            },
            child: Text(l == AppLanguage.kyrgyz ? 'Чыгуу' : 'Выйти', style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String num;
  final String label;
  const _StatCard({required this.num, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark),
        ),
        child: Column(children: [
          Text(num, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 17, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 9.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _MenuRow({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = danger ? AppColors.red : scheme.onSurfaceVariant;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: AppColors.softShadow(dark: dark),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: danger ? AppColors.red.withValues(alpha: .10) : scheme.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: danger ? AppColors.red : scheme.onSurface))),
            if (!danger) Icon(Icons.chevron_right, size: 18, color: scheme.primary.withValues(alpha: .65)),
          ],
        ),
      ),
      ),
    );
  }
}
