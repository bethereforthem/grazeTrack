import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/locale_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Account Section ───────────────────────────
          _SectionHeader(l10n.accountSection),
          _SettingsTile(
            icon: Icons.person_outlined,
            title: l10n.myProfile,
            subtitle: l10n.updateNamePhone,
            onTap: () => context.push('/profile'),
          ),
          _SettingsTile(
            icon: Icons.lock_outlined,
            title: l10n.changePassword,
            subtitle: l10n.updateLoginPassword,
            onTap: () => AppUtils.showSnackBar(
                context, l10n.changePasswordTitle),
          ),

          const SizedBox(height: 16),

          // ─── Language Section ───────────────────────────
          _SectionHeader(l10n.languageSection),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
              title: Text(l10n.language),
              subtitle: Text(
                kLocaleNativeNames[currentLocale.languageCode] ?? 'English',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showLanguagePicker(context, ref, currentLocale, l10n),
            ),
          ),

          const SizedBox(height: 16),

          // ─── Currency Section ───────────────────────────
          _SectionHeader(l10n.currencySection),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.currency_exchange,
                  color: AppTheme.primaryGreen),
              title: Text(l10n.displayCurrency),
              subtitle: Text(
                '${currencyState.code} — ${currencyState.symbol}  '
                '${currencyState.isLoading ? l10n.fetchingRates : ""}',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () =>
                  _showCurrencyPicker(context, ref, currencyState.code, l10n),
            ),
          ),

          const SizedBox(height: 16),

          // ─── App Section ───────────────────────────────
          _SectionHeader(l10n.appSection),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: l10n.manageReminders,
            onTap: () => context.push('/notifications'),
          ),
          _SettingsTile(
            icon: Icons.bar_chart,
            title: l10n.reports,
            subtitle: l10n.viewAnalytics,
            onTap: () => context.go('/reports'),
          ),

          const SizedBox(height: 16),

          // ─── Network Section ───────────────────────────
          _SectionHeader(l10n.networkSection),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.dns_outlined,
                  color: AppTheme.primaryGreen),
              title: Text(l10n.serverAddress),
              subtitle: Text(
                AppConstants.baseUrl,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.edit_outlined,
                  color: Colors.grey, size: 20),
              onTap: () => _showServerUrlDialog(context, l10n),
            ),
          ),

          const SizedBox(height: 16),

          // ─── Support Section ───────────────────────────
          _SectionHeader(l10n.supportSection),
          _SettingsTile(
            icon: Icons.help_outline,
            title: l10n.helpFaq,
            subtitle: l10n.getAnswers,
            onTap: () => context.push('/help-faq'),
          ),
          _SettingsTile(
            icon: Icons.support_agent_outlined,
            title: l10n.contactSupport,
            subtitle: l10n.chatEmailCallTeam,
            onTap: () => context.push('/contact'),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l10n.appVersion,
            subtitle: l10n.appVersionValue,
            onTap: null,
          ),

          const SizedBox(height: 24),

          // ─── Logout ────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await AppUtils.showConfirmDialog(
                context,
                title: l10n.logout,
                message: l10n.logoutConfirm,
                confirmText: l10n.logout,
              );
              if (confirm) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: Text(l10n.logout,
                style: const TextStyle(color: Colors.red, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref,
      Locale currentLocale, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final languages = [
          {'code': 'en', 'name': l10n.english, 'native': 'English'},
          {'code': 'fr', 'name': l10n.french, 'native': 'Français'},
          {'code': 'rw', 'name': l10n.kinyarwanda, 'native': 'Ikinyarwanda'},
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(l10n.selectLanguage,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ...languages.map((lang) {
              final isSelected =
                  currentLocale.languageCode == lang['code'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.backgroundGreen,
                  child: Text(
                    (lang['code'] as String).toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(lang['native'] as String,
                    style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal)),
                subtitle: Text(lang['name'] as String,
                    style: const TextStyle(fontSize: 12)),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppTheme.primaryGreen)
                    : null,
                onTap: () {
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(lang['code'] as String));
                  Navigator.pop(context);
                  AppUtils.showSnackBar(context, l10n.languageChanged);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showServerUrlDialog(BuildContext context, AppLocalizations l10n) {
    final ctrl = TextEditingController(text: AppConstants.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.serverAddress),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.serverAddressInstruction,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'http://192.168.x.x:5000/api/v1',
                prefixIcon: Icon(Icons.dns_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await AppConstants.resetServerUrl();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                AppUtils.showSnackBar(
                    context, l10n.resetToDefault(AppConstants.baseUrl));
              }
            },
            child: Text(l10n.reset,
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = ctrl.text.trim();
              if (url.isEmpty) return;
              await AppConstants.saveServerUrl(url);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                AppUtils.showSnackBar(context, l10n.serverAddressUpdated);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref,
      String currentCode, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l10n.selectCurrency,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: kCurrencySymbols.entries.map((entry) {
                final isSelected = entry.key == currentCode;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? AppTheme.primaryGreen
                        : AppTheme.backgroundGreen,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(entry.key,
                      style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppTheme.primaryGreen)
                      : null,
                  onTap: () {
                    ref
                        .read(currencyProvider.notifier)
                        .selectCurrency(entry.key);
                    Navigator.pop(context);
                    AppUtils.showSnackBar(
                        context, l10n.currencyChanged(entry.key));
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
              letterSpacing: 1)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }
}
