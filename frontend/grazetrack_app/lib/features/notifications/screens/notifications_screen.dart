import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notification_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _upcoming = [];
  bool _upcomingLoading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(notificationProvider.notifier).load();
      _loadUpcoming();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadUpcoming() async {
    setState(() => _upcomingLoading = true);
    try {
      final res = await _api.get('/health/upcoming');
      if (mounted) {
        setState(() {
          _upcoming = List<Map<String, dynamic>>.from(
              res.data['data'] as List? ?? []);
          _upcomingLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _upcomingLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final l10n = AppLocalizations.of(context);
    final unread = state.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationProvider.notifier).markAllRead(),
              child: Text(l10n.markAllRead,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.alertsTab),
                  if (unread > 0) ...[
                    const SizedBox(width: 6),
                    Badge(
                      label: Text('$unread'),
                      backgroundColor: Colors.redAccent,
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: l10n.remindersTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _AlertsTab(state: state),
          _RemindersTab(
            upcoming: _upcoming,
            isLoading: _upcomingLoading,
            onRefresh: _loadUpcoming,
          ),
        ],
      ),
    );
  }
}

class _AlertsTab extends ConsumerWidget {
  final NotificationState state;
  const _AlertsTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noNotifications,
                style: const TextStyle(fontSize: 17, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(l10n.alertsSubtitle,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(notificationProvider.notifier).load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: state.notifications.length,
        itemBuilder: (_, i) {
          final n = state.notifications[i];
          final isUnread = n['read'] == false;
          final type = (n['data']?['type'] as String?) ?? '';

          return Dismissible(
            key: Key(n['id'] ?? i.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.redAccent,
              child: const Icon(Icons.delete_outline,
                  color: Colors.white),
            ),
            onDismissed: (_) =>
                ref.read(notificationProvider.notifier).markRead(n['id']),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isUnread
                  ? AppTheme.primaryGreen.withAlpha(12)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isUnread
                    ? const BorderSide(
                        color: AppTheme.primaryGreen, width: 1)
                    : BorderSide.none,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                leading: CircleAvatar(
                  backgroundColor: _bgColor(type),
                  child: Icon(_icon(type), color: _iconColor(type), size: 20),
                ),
                title: Row(children: [
                  Expanded(
                    child: Text(
                      n['title'] ?? 'Notification',
                      style: TextStyle(
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle),
                    ),
                ]),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((n['body'] ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 4),
                        child: Text(n['body'],
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ),
                    Text(
                      AppUtils.formatDate(n['createdAt'] ?? ''),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                isThreeLine: (n['body'] ?? '').isNotEmpty,
                onTap: isUnread
                    ? () => ref
                        .read(notificationProvider.notifier)
                        .markRead(n['id'])
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'chat_message':
        return Icons.chat_bubble_outline;
      case 'order_update':
        return Icons.receipt_long_outlined;
      case 'payment':
        return Icons.attach_money;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _bgColor(String type) {
    switch (type) {
      case 'chat_message':
        return Colors.blue.withAlpha(30);
      case 'order_update':
        return Colors.orange.withAlpha(30);
      case 'payment':
        return Colors.green.withAlpha(30);
      default:
        return AppTheme.backgroundGreen;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'chat_message':
        return Colors.blue;
      case 'order_update':
        return AppTheme.warningOrange;
      case 'payment':
        return AppTheme.profitGreen;
      default:
        return AppTheme.primaryGreen;
    }
  }
}

class _RemindersTab extends StatelessWidget {
  final List<Map<String, dynamic>> upcoming;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _RemindersTab({
    required this.upcoming,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (upcoming.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(l10n.allUpToDate,
                style: const TextStyle(fontSize: 17, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(l10n.noUpcomingHealthChecks,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: upcoming.length,
        itemBuilder: (_, i) {
          final rec = upcoming[i];
          final date = rec['nextCheckupDate'] as String? ?? '';
          final daysUntil = _daysUntil(date);
          final isUrgent = daysUntil >= 0 && daysUntil <= 7;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: isUrgent ? const Color(0xFFFFF3E0) : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isUrgent ? const Color(0xFFFFE0B2) : AppTheme.backgroundGreen,
                child: Icon(
                  Icons.vaccines_outlined,
                  color: isUrgent
                      ? AppTheme.warningOrange
                      : AppTheme.primaryGreen,
                ),
              ),
              title: Text(
                rec['vaccination'] as String? ??
                    rec['type'] as String? ??
                    'Health Check',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${l10n.dueLabel}: ${AppUtils.formatDate(date)}'
                '${daysUntil >= 0 ? '  (${l10n.daysAway(daysUntil)})' : '  (${l10n.overdue})'}',
                style: TextStyle(
                    color: isUrgent
                        ? AppTheme.warningOrange
                        : Colors.grey),
              ),
              trailing: isUrgent
                  ? const Icon(Icons.warning_amber_outlined,
                      color: AppTheme.warningOrange)
                  : const Icon(Icons.notifications_active_outlined,
                      color: AppTheme.primaryGreen),
            ),
          );
        },
      ),
    );
  }

  int _daysUntil(String isoDate) {
    try {
      final due = DateTime.parse(isoDate);
      return due.difference(DateTime.now()).inDays;
    } catch (_) {
      return 999;
    }
  }
}
