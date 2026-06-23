import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/animal_provider.dart';
import '../models/animal_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';

class AnimalListScreen extends ConsumerStatefulWidget {
  const AnimalListScreen({super.key});

  @override
  ConsumerState<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends ConsumerState<AnimalListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GoRouter? _router;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      if (!mounted) return;
      ref.read(animalProvider.notifier).loadAnimals();
      _router = GoRouter.of(context);
      _router!.routeInformationProvider.addListener(_onRouteChange);
    });
  }

  void _onRouteChange() {
    if (!mounted) return;
    final path = _router?.routeInformationProvider.value.uri.path ?? '';
    if (path == '/animals') {
      ref.read(animalProvider.notifier).loadAnimals();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _router?.routeInformationProvider.removeListener(_onRouteChange);
    super.dispose();
  }

  List<AnimalModel> _filtered(List<AnimalModel> list) {
    return list.where((a) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.type.toLowerCase().contains(q) ||
          a.breed.toLowerCase().contains(q);
      final matchesType = _selectedType == 'All' ||
          a.type.toLowerCase() == _selectedType.toLowerCase();
      return matchesSearch && matchesType;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'sold':
        return Colors.blue;
      case 'deceased':
        return Colors.red;
      default:
        return AppTheme.primaryGreen;
    }
  }

  Widget _buildActiveList(List<AnimalModel> animals, AppLocalizations l10n) {
    if (animals.isEmpty) return _emptyState(l10n);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: animals.length,
      itemBuilder: (ctx, i) {
        final animal = animals[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.backgroundGreen,
                      child: Text(
                        animal.type.isNotEmpty
                            ? animal.type[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            animal.name.isNotEmpty ? animal.name : animal.type,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          Text(
                            '${animal.breed.isNotEmpty ? animal.breed : animal.type}'
                            ' • ${animal.currentAge} ${l10n.months}'
                            ' • ${animal.gender}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              animal.status.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                            backgroundColor: _statusColor(animal.status),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                    _AnimalMenuButton(
                      l10n: l10n,
                      onViewDetails: () =>
                          context.push('/animals/${animal.id}'),
                      onUpdate: () =>
                          context.push('/animals/update/${animal.id}'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.purchaseCost}: ${AppUtils.formatCurrency(animal.purchaseCost)}',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInactiveList(List<AnimalModel> animals, AppLocalizations l10n) {
    if (animals.isEmpty) return _emptyState(l10n);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: animals.length,
      itemBuilder: (ctx, i) {
        final animal = animals[i];
        final isSold = animal.status == 'sold';
        final statusColor = isSold ? Colors.blue : Colors.red;
        final dateLabel = isSold ? l10n.dateSold : l10n.dateOfDeath;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: statusColor.withAlpha(30),
                      child: Text(
                        animal.type.isNotEmpty
                            ? animal.type[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            animal.name.isNotEmpty ? animal.name : animal.type,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          Text(
                            '${animal.breed.isNotEmpty ? animal.breed : animal.type}'
                            ' • ${animal.gender}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        animal.status.toUpperCase(),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: statusColor,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _InfoLine(
                  icon: Icons.attach_money,
                  label: l10n.costOfBuying,
                  value: AppUtils.formatCurrency(animal.purchaseCost),
                ),
                const SizedBox(height: 6),
                _InfoLine(
                  icon: Icons.calendar_today_outlined,
                  label: l10n.dateOfBuy,
                  value: animal.createdAt.isNotEmpty
                      ? AppUtils.formatDate(animal.createdAt)
                      : '—',
                ),
                const SizedBox(height: 6),
                _InfoLine(
                  icon: isSold
                      ? Icons.sell_outlined
                      : Icons.sentiment_very_dissatisfied_outlined,
                  label: dateLabel,
                  value: (animal.soldAt != null && animal.soldAt!.isNotEmpty)
                      ? AppUtils.formatDate(animal.soldAt!)
                      : '—',
                  valueColor: statusColor,
                ),
                if (isSold && animal.soldPrice != null) ...[
                  const SizedBox(height: 6),
                  _InfoLine(
                    icon: Icons.price_check,
                    label: l10n.soldPrice,
                    value: AppUtils.formatCurrency(animal.soldPrice!),
                    valueColor: Colors.blue,
                  ),
                  const SizedBox(height: 6),
                  _InfoLine(
                    icon: Icons.trending_up,
                    label: l10n.profitLoss,
                    value: AppUtils.profitLabel(
                        animal.soldPrice! - animal.purchaseCost),
                    valueColor: AppUtils.profitColor(
                        animal.soldPrice! - animal.purchaseCost),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Icon(Icons.pets, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(l10n.noAnimalsInCategory,
                style: const TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(animalProvider);
    final l10n = AppLocalizations.of(context);

    final active   = _filtered(state.animals.where((a) => a.status == 'active').toList());
    final sold     = _filtered(state.animals.where((a) => a.status == 'sold').toList());
    final deceased = _filtered(state.animals.where((a) => a.status == 'deceased').toList());
    final hasFilter = _selectedType != 'All';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAnimalsCount(state.animals.length)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/animals/add'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFF81C784)),
                const SizedBox(width: 6),
                Text(l10n.activeCount(active.length)),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.circle, size: 8, color: Colors.lightBlueAccent),
                const SizedBox(width: 6),
                Text(l10n.soldCount(sold.length)),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.circle, size: 8, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(l10n.deceasedCount(deceased.length)),
              ]),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Search bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                hintText: l10n.searchByNameTypeBreed,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ─── Category filter ──────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _AnimalTypeFilter(
                  value: _selectedType,
                  items: [l10n.all, ...AppConstants.animalTypes],
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                if (hasFilter) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 14),
                    label: Text(l10n.clear,
                        style: const TextStyle(fontSize: 12)),
                    onPressed: () => setState(() => _selectedType = 'All'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ─── Tab body ─────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(state.error!,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => ref
                                  .read(animalProvider.notifier)
                                  .loadAnimals(),
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(animalProvider.notifier).loadAnimals(),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildActiveList(active, l10n),
                            _buildInactiveList(sold, l10n),
                            _buildInactiveList(deceased, l10n),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/animals/add'),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.addAnimal,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _AnimalTypeFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _AnimalTypeFilter({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value != 'All' && value != AppLocalizations.of(context).all;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryGreen.withAlpha(20)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive
                ? AppTheme.primaryGreen.withAlpha(120)
                : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets,
              size: 14,
              color: isActive ? AppTheme.primaryGreen : Colors.grey),
          const SizedBox(width: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              isDense: true,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppTheme.primaryGreen : Colors.black87,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              items: items
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalMenuButton extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback onViewDetails;
  final VoidCallback onUpdate;

  const _AnimalMenuButton({
    required this.l10n,
    required this.onViewDetails,
    required this.onUpdate,
  });

  @override
  State<_AnimalMenuButton> createState() => _AnimalMenuButtonState();
}

class _AnimalMenuButtonState extends State<_AnimalMenuButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: PopupMenuButton<String>(
        tooltip: widget.l10n.options,
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.primaryGreen
                : AppTheme.primaryGreen.withAlpha(200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        onSelected: (value) {
          if (value == 'view') widget.onViewDetails();
          if (value == 'update') widget.onUpdate();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                const Icon(Icons.visibility_outlined,
                    color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: 10),
                Text(widget.l10n.viewDetails,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'update',
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                Text(widget.l10n.update,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
