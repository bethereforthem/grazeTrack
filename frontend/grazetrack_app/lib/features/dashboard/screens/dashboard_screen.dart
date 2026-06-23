import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../dashboard_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../auth/auth_provider.dart';
import '../../notifications/notification_provider.dart';
import '../../../l10n/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _userName = '';
  List<Map<String, dynamic>> _latestListings = [];
  bool _listingsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).loadStats();
      ref.read(notificationProvider.notifier).load();
      _loadLatestListings();
    });
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted && user != null) {
      setState(() => _userName = user['name'] ?? '');
    }
  }

  Future<void> _loadLatestListings() async {
    try {
      final res = await ApiService().get('/listings');
      final data = res.data as Map<String, dynamic>;
      final all = List<Map<String, dynamic>>.from(data['data'] ?? []);
      if (mounted) {
        setState(() {
          _latestListings = all.take(3).toList();
          _listingsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _listingsLoading = false);
    }
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final unreadCount =
        ref.watch(notificationProvider.select((s) => s.unreadCount));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardProvider.notifier).loadStats();
          await _loadLatestListings();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ─── Gradient App Bar ─────────────────────────────
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${_greeting(l10n)},',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _userName.isEmpty ? l10n.farmerDefault : _userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.farmOverview,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () => context.push('/notifications'),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      context.push('/profile');
                    } else if (value == 'logout') {
                      final confirm = await AppUtils.showConfirmDialog(
                        context,
                        title: l10n.logout,
                        message: l10n.logoutConfirm,
                        confirmText: l10n.logout,
                      );
                      if (confirm && context.mounted) {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'profile',
                        child: Row(children: [
                          const Icon(Icons.person_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.myProfile),
                        ])),
                    PopupMenuItem(
                        value: 'logout',
                        child: Row(children: [
                          const Icon(Icons.logout, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(l10n.logout,
                              style: const TextStyle(color: Colors.red)),
                        ])),
                  ],
                ),
              ],
            ),

            // ─── Body content ──────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Stats Grid ────────────────────────────────
                  if (state.isLoading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ))
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          title: l10n.activeAnimals,
                          value: '${state.stats['totalActiveAnimals'] ?? 0}',
                          icon: Icons.pets,
                          color: AppTheme.primaryGreen,
                          onTap: () => context.go('/animals'),
                        ),
                        _StatCard(
                          title: l10n.totalRevenue,
                          value: AppUtils.formatCurrency(
                              (state.stats['totalRevenue'] ?? 0).toDouble()),
                          icon: Icons.attach_money,
                          color: Colors.blue[700]!,
                          onTap: () => context.go('/reports'),
                        ),
                        _StatCard(
                          title: l10n.expenses,
                          value: AppUtils.formatCurrency(
                              (state.stats['allTimeExpenses'] ?? 0).toDouble()),
                          icon: Icons.receipt_long,
                          color: AppTheme.warningOrange,
                          onTap: () => context.go('/expenses'),
                        ),
                        _StatCard(
                          title: l10n.totalProfit,
                          value: AppUtils.formatCurrency(
                              (state.stats['totalProfit'] ?? 0).toDouble()),
                          icon: Icons.trending_up,
                          color: (state.stats['totalProfit'] ?? 0) >= 0
                              ? AppTheme.profitGreen
                              : AppTheme.lossRed,
                          onTap: () => context.go('/reports'),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // ── Quick Actions ─────────────────────────────
                  _SectionHeader(title: l10n.quickActions),
                  const SizedBox(height: 12),
                  Row(children: [
                    _ActionButton(
                        label: l10n.addAnimal,
                        icon: Icons.add_circle_outline,
                        onTap: () => context.push('/animals/add')),
                    const SizedBox(width: 8),
                    _ActionButton(
                        label: l10n.recordFeed,
                        icon: Icons.grass,
                        onTap: () => context.push('/feed/add')),
                    const SizedBox(width: 8),
                    _ActionButton(
                        label: l10n.healthLog,
                        icon: Icons.medical_services_outlined,
                        onTap: () => context.push('/health/add')),
                    const SizedBox(width: 8),
                    _ActionButton(
                        label: l10n.recordSale,
                        icon: Icons.sell_outlined,
                        onTap: () => context.push('/sales/add')),
                  ]),

                  const SizedBox(height: 24),

                  // ── Marketplace Quick Links ────────────────────
                  _SectionHeader(
                    title: l10n.marketplace,
                    actionLabel: l10n.browseAll,
                    onAction: () => context.go('/marketplace'),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    _ActionButton(
                        label: l10n.browse,
                        icon: Icons.storefront_outlined,
                        onTap: () => context.go('/marketplace')),
                    const SizedBox(width: 8),
                    _ActionButton(
                        label: l10n.sellAnimal,
                        icon: Icons.sell_outlined,
                        onTap: () => context.push('/my-listings/create')),
                    const SizedBox(width: 8),
                    _ActionButton(
                        label: l10n.myListings,
                        icon: Icons.list_alt_outlined,
                        onTap: () => context.push('/my-listings')),
                    const SizedBox(width: 8),
                    _ActionButton(
                        label: l10n.myOrders,
                        icon: Icons.receipt_long_outlined,
                        onTap: () => context.push('/orders')),
                  ]),

                  const SizedBox(height: 24),

                  // ── Animal Categories Quick Filter ─────────────
                  _SectionHeader(title: l10n.browseByCategory),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryChip(emoji: '🐄', label: l10n.cowsLabel, type: 'Cow'),
                        _CategoryChip(emoji: '🐐', label: l10n.goatsLabel, type: 'Goat'),
                        _CategoryChip(emoji: '🐑', label: l10n.sheepLabel, type: 'Sheep'),
                        _CategoryChip(emoji: '🐖', label: l10n.pigsLabel, type: 'Pig'),
                        _CategoryChip(emoji: '🐔', label: l10n.chickensLabel, type: 'Chicken'),
                        _CategoryChip(emoji: '🐴', label: l10n.horsesLabel, type: 'Horse'),
                        _CategoryChip(emoji: '🐪', label: l10n.camelsLabel, type: 'Camel'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Latest Marketplace Listings preview ────────
                  _SectionHeader(
                    title: l10n.latestListings,
                    actionLabel: l10n.seeAll,
                    onAction: () => context.go('/marketplace'),
                  ),
                  const SizedBox(height: 12),
                  if (_listingsLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_latestListings.isEmpty)
                    _EmptyMarketplaceCard(l10n: l10n)
                  else
                    Column(
                      children: _latestListings
                          .map((l) => _MarketplacePreviewTile(listing: l))
                          .toList(),
                    ),

                  const SizedBox(height: 24),

                  // ── Navigation shortcuts ───────────────────────
                  _SectionHeader(title: l10n.more),
                  const SizedBox(height: 8),
                  _NavTile(
                      icon: Icons.chat_bubble_outline,
                      label: l10n.messages,
                      subtitle: l10n.chatWithBuyers,
                      onTap: () => context.push('/chat')),
                  const SizedBox(height: 8),
                  _NavTile(
                      icon: Icons.admin_panel_settings_outlined,
                      label: l10n.orderManagement,
                      subtitle: l10n.adminOrders,
                      onTap: () => context.push('/orders/admin')),
                  const SizedBox(height: 8),
                  _NavTile(
                      icon: Icons.settings_outlined,
                      label: l10n.settings,
                      subtitle: l10n.profileCurrencyPrefs,
                      onTap: () => context.push('/settings')),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!,
                style: const TextStyle(
                    color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 13),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 26),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold, color: color)),
                Text(title,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String type;
  const _CategoryChip(
      {required this.emoji, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.go('/marketplace'),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.primaryGreen.withAlpha(40)
              : AppTheme.backgroundGreen,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppTheme.primaryGreen.withAlpha(60), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen)),
          ],
        ),
      ),
    );
  }
}

class _MarketplacePreviewTile extends StatelessWidget {
  final Map<String, dynamic> listing;
  const _MarketplacePreviewTile({required this.listing});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(listing['images'] ?? []);
    return GestureDetector(
      onTap: () =>
          context.push('/marketplace/${listing['id']}', extra: listing),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: images.isNotEmpty
                  ? Image.network(images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${listing['animalType'] ?? ''} — ${listing['breed'] ?? ''}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        listing['farmLocation'] ?? '',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                      AppUtils.formatCurrency(
                          (listing['price'] ?? 0).toDouble()),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.pets, size: 32, color: Colors.grey),
      );
}

class _EmptyMarketplaceCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyMarketplaceCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/marketplace'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppTheme.primaryGreen.withAlpha(50),
              style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            const Icon(Icons.storefront_outlined,
                color: AppTheme.primaryGreen, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.noListingsYet,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen)),
                  Text(l10n.beFirstToSell,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      tileColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryGreen.withAlpha(20),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 30 : 13),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryGreen, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
