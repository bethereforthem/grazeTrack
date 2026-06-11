import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_provider.dart';
import '../providers/currency_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Account Section ───────────────────────────
          const _SectionHeader('Account'),
          _SettingsTile(
            icon: Icons.person_outlined,
            title: 'My Profile',
            subtitle: 'Update your name and phone number',
            onTap: () => context.push('/profile'),
          ),
          _SettingsTile(
            icon: Icons.lock_outlined,
            title: 'Change Password',
            subtitle: 'Update your login password',
            onTap: () =>
                AppUtils.showSnackBar(context, 'Navigate to change password screen'),
          ),

          const SizedBox(height: 16),

          // ─── Currency Section ───────────────────────────
          const _SectionHeader('Currency'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.currency_exchange, color: AppTheme.primaryGreen),
              title: const Text('Display Currency'),
              subtitle: Text(
                '${currencyState.code} — ${currencyState.symbol}  '
                '${currencyState.isLoading ? "(fetching rates...)" : ""}',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showCurrencyPicker(context, ref, currencyState.code),
            ),
          ),

          const SizedBox(height: 16),

          // ─── App Section ───────────────────────────────
          const _SectionHeader('App'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage reminders and alerts',
            onTap: () => context.push('/notifications'),
          ),
          _SettingsTile(
            icon: Icons.bar_chart,
            title: 'Reports',
            subtitle: 'View analytics and insights',
            onTap: () => context.go('/reports'),
          ),

          const SizedBox(height: 16),

          // ─── Network Section ───────────────────────────
          const _SectionHeader('Network'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.dns_outlined,
                  color: AppTheme.primaryGreen),
              title: const Text('Server Address'),
              subtitle: Text(
                AppConstants.baseUrl,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.edit_outlined,
                  color: Colors.grey, size: 20),
              onTap: () => _showServerUrlDialog(context),
            ),
          ),

          const SizedBox(height: 16),

          // ─── Support Section ───────────────────────────
          const _SectionHeader('Support'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & FAQ',
            subtitle: 'Get answers to common questions',
            onTap: () => context.push('/help-faq'),
          ),
          _SettingsTile(
            icon: Icons.support_agent_outlined,
            title: 'Contact Support',
            subtitle: 'Chat, email, or call our team',
            onTap: () => context.push('/contact'),
          ),
          const _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: 'GrazeTrack v1.0.0',
            onTap: null,
          ),

          const SizedBox(height: 24),

          // ─── Logout ────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await AppUtils.showConfirmDialog(
                context,
                title: 'Logout',
                message: 'Are you sure you want to logout?',
                confirmText: 'Logout',
              );
              if (confirm) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Logout',
                style: TextStyle(color: Colors.red, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showServerUrlDialog(BuildContext context) {
    final ctrl =
        TextEditingController(text: AppConstants.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your PC\'s local IP address.\nExample: http://192.168.1.x:5000/api/v1',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    context, 'Reset to default: ${AppConstants.baseUrl}');
              }
            },
            child: const Text('Reset',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = ctrl.text.trim();
              if (url.isEmpty) return;
              await AppConstants.saveServerUrl(url);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                AppUtils.showSnackBar(context, 'Server address updated');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, WidgetRef ref, String currentCode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Select Currency',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
                        context, 'Currency changed to ${entry.key}');
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
