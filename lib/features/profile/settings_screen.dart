import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_role.dart';
import '../../state/user_provider.dart';
import '../../state/app_settings_provider.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.language;
    final dark = settings.isDark;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.settings(s))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          _SectionTitle(text: s == AppLanguage.kyrgyz ? 'СЫРТКЫ КӨРҮНҮШ' : 'ВНЕШНИЙ ВИД'),
          _SettingsCard(
            child: Column(
              children: [
                _SettingsRow(
                  icon: dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  title: s == AppLanguage.kyrgyz ? 'Тема' : 'Тема',
                  subtitle: dark
                      ? (s == AppLanguage.kyrgyz ? 'Караңгы режим' : 'Тёмная тема')
                      : (s == AppLanguage.kyrgyz ? 'Жарык режим' : 'Светлая тема'),
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, icon: const Icon(Icons.light_mode_outlined, size: 17), label: Text(s == AppLanguage.kyrgyz ? 'Жарык' : 'Светлая')),
                    ButtonSegment(value: true, icon: const Icon(Icons.dark_mode_outlined, size: 17), label: Text(s == AppLanguage.kyrgyz ? 'Караңгы' : 'Тёмная')),
                  ],
                  selected: {dark},
                  onSelectionChanged: (values) => context.read<AppSettingsProvider>().setThemeMode(values.first ? ThemeMode.dark : ThemeMode.light),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _SectionTitle(text: s == AppLanguage.kyrgyz ? 'ТИЛ' : 'ЯЗЫК'),
          _SettingsCard(
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.translate_rounded,
                  title: s == AppLanguage.kyrgyz ? 'Тил интерфейси' : 'Язык интерфейса',
                  subtitle: settings.language == AppLanguage.kyrgyz ? 'Кыргызча' : 'Русский',
                ),
                const SizedBox(height: 12),
                SegmentedButton<AppLanguage>(
                  segments: const [
                    ButtonSegment(value: AppLanguage.russian, icon: Icon(Icons.language, size: 17), label: Text('Русский')),
                    ButtonSegment(value: AppLanguage.kyrgyz, icon: Icon(Icons.language, size: 17), label: Text('Кыргызча')),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (values) => context.read<AppSettingsProvider>().setLanguage(values.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _SectionTitle(text: AppStrings.security(s)),
          _SettingsCard(
            child: Column(
              children: [
                InkWell(
                  onTap: () => context.push('/change-password'),
                  borderRadius: BorderRadius.circular(12),
                  child: _SettingsRow(
                    icon: Icons.lock_outline_rounded,
                    title: AppStrings.changePassword(s),
                    subtitle: AppStrings.changePasswordHint(s),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
          if (context.watch<UserProvider>().role == UserRole.buyer) ...[
            const SizedBox(height: 22),
            _SectionTitle(text: AppStrings.payments(s)),
            _SettingsCard(
              child: InkWell(
                onTap: () => context.push('/payments'),
                child: _SettingsRow(
                  icon: Icons.credit_card_outlined,
                  title: AppStrings.payments(s),
                  subtitle: AppStrings.addCard(s),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          _SectionTitle(text: s == AppLanguage.kyrgyz ? 'КОШУМЧА' : 'ДОПОЛНИТЕЛЬНО'),
          _SettingsCard(
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.notifications_none_rounded,
                  title: s == AppLanguage.kyrgyz ? 'Билдирмелер' : 'Уведомления',
                  subtitle: s == AppLanguage.kyrgyz ? 'Заказдар жана маанилүү жаңылыктар' : 'Заказы и важные обновления',
                  trailing: Switch.adaptive(
                    value: settings.notificationsEnabled,
                    onChanged: context.read<AppSettingsProvider>().setNotifications,
                  ),
                ),
                const Divider(height: 22),
                _SettingsRow(
                  icon: Icons.security_outlined,
                  title: s == AppLanguage.kyrgyz ? 'Купуялык' : 'Конфиденциальность',
                  subtitle: s == AppLanguage.kyrgyz ? 'Маалыматтарыңыз түзмөктө корголот' : 'Ваши настройки хранятся на устройстве',
                ),
                const Divider(height: 22),
                _SettingsRow(
                  icon: Icons.info_outline_rounded,
                  title: s == AppLanguage.kyrgyz ? 'Тиркеме жөнүндө' : 'О приложении',
                  subtitle: 'ЭлектроМаркет • 0.1.0',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _SectionTitle(text: s == AppLanguage.kyrgyz ? 'АККАУНТ ЖАНА ЖАРДАМ' : 'АККАУНТ И ПОМОЩЬ'),
          _SettingsCard(
            child: Column(
              children: [
                InkWell(
                  onTap: () => context.push('/edit-profile'),
                  child: _SettingsRow(
                    icon: Icons.person_outline_rounded,
                    title: s == AppLanguage.kyrgyz ? 'Жеке маалыматтар' : 'Личные данные',
                    subtitle: s == AppLanguage.kyrgyz ? 'Атыңыз, телефон жана профиль' : 'Имя, телефон и профиль',
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  ),
                ),
                const Divider(height: 22),
                InkWell(
                  onTap: () => context.push('/support'),
                  child: _SettingsRow(
                    icon: Icons.support_agent_outlined,
                    title: s == AppLanguage.kyrgyz ? 'Колдоо кызматы' : 'Поддержка',
                    subtitle: s == AppLanguage.kyrgyz ? 'Сурооңуз болсо бизге жазыңыз' : 'Свяжитесь с нами, если нужна помощь',
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              s == AppLanguage.kyrgyz ? 'Электр товарлары үчүн жөнөкөй жана ыңгайлуу маркет.' : 'Простой маркетплейс для электротехнических товаров.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 3, bottom: 8),
        child: Text(text, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: .7, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: AppColors.cardShadow(dark: Theme.of(context).brightness == Brightness.dark),
        ),
        child: child,
      );
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  const _SettingsRow({required this.icon, required this.title, required this.subtitle, this.trailing});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(fontSize: 10.5, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.3)),
            ]),
          ),
          if (trailing != null) trailing!,
        ],
      );
}
