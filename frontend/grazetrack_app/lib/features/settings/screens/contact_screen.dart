import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Hero card ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent, size: 56, color: Colors.white),
                const SizedBox(height: 12),
                Text(l10n.weAreHereToHelp,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  l10n.supportHours,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Live support chat ───────────────────────────────────────
          _SectionLabel(l10n.liveSupport),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: const CircleAvatar(
                backgroundColor: AppTheme.backgroundGreen,
                child: Icon(Icons.chat_bubble_outline,
                    color: AppTheme.primaryGreen),
              ),
              title: Text(l10n.chatWithSupportTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.chatWithSupportSubtitle),
              trailing: ElevatedButton(
                onPressed: () => context.go('/chat'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
                child: Text(l10n.openChat),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Contact details ─────────────────────────────────────────
          _SectionLabel(l10n.contactDetailsSection),
          _ContactTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'support@grazetrack.com',
            onTap: () => _copy(context, 'support@grazetrack.com'),
            badge: l10n.tapToCopy,
          ),
          _ContactTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '+1 (800) 472-9385',
            onTap: () => _copy(context, '+18004729385'),
            badge: l10n.tapToCopy,
          ),
          const _ContactTile(
            icon: Icons.language_outlined,
            label: 'Website',
            value: 'www.grazetrack.com',
            onTap: null,
          ),

          const SizedBox(height: 20),

          // ── Response time info ──────────────────────────────────────
          _SectionLabel(l10n.responseTimesSection),
          const _InfoRow(Icons.chat_bubble_outline, 'Live Chat', 'Under 5 minutes'),
          const _InfoRow(Icons.email_outlined, 'Email', 'Within 24 hours'),
          const _InfoRow(Icons.phone_outlined, 'Phone', 'Mon–Fri, 8am – 6pm'),

          const SizedBox(height: 20),

          // ── Before you contact ──────────────────────────────────────
          _SectionLabel(l10n.beforeContactUs),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.faqInstantAnswer,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/help-faq'),
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: Text(l10n.browseHelpFaq),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── App info ────────────────────────────────────────────────
          _SectionLabel(l10n.appInformation),
          const _InfoRow(Icons.info_outline, 'Version', 'GrazeTrack v1.0.0'),
          const _InfoRow(
              Icons.policy_outlined, 'Privacy Policy', 'www.grazetrack.com/privacy'),
          const _InfoRow(
              Icons.description_outlined, 'Terms of Service', 'www.grazetrack.com/terms'),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copied(text)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Reusable section label ────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
            letterSpacing: 1),
      ),
    );
  }
}

// ── Contact tile with copy action ─────────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? badge;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: onTap != null && badge != null
            ? Chip(
                label: Text(badge!,
                    style: const TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        title: Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
        trailing: Text(value,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}
