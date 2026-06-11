import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/animal_provider.dart';
import '../models/animal_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';

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

  // ─── Active animals list ─────────────────────────────────────────────────
  // Each card has a visible popup menu with "View Details" and "Update".
  // No delete option.
  Widget _buildActiveList(List<AnimalModel> animals) {
    if (animals.isEmpty) return _emptyState();

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
                // ─── Header row ──────────────────────────────────
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
                            ' • ${animal.currentAge} months'
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

                    // ─── Popup menu — clearly visible green button ────
                    _AnimalMenuButton(
                      onViewDetails: () =>
                          context.push('/animals/${animal.id}'),
                      onUpdate: () =>
                          context.push('/animals/update/${animal.id}'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ─── Purchase cost ───────────────────────────────────
                Text(
                  'Purchase Cost: ${AppUtils.formatCurrency(animal.purchaseCost)}',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Sold / Deceased animals list ───────────────────────────────────────
  // Simple read-only cards: name, cost of buying, date of buy, date sold/died.
  // No action buttons at all.
  Widget _buildInactiveList(List<AnimalModel> animals) {
    if (animals.isEmpty) return _emptyState();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: animals.length,
      itemBuilder: (ctx, i) {
        final animal = animals[i];
        final isSold = animal.status == 'sold';
        final statusColor = isSold ? Colors.blue : Colors.red;
        final dateLabel = isSold ? 'Date Sold' : 'Date of Death';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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

                // Info rows
                _InfoLine(
                  icon: Icons.attach_money,
                  label: 'Cost of Buying',
                  value: AppUtils.formatCurrency(animal.purchaseCost),
                ),
                const SizedBox(height: 6),
                _InfoLine(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date of Buy',
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

                // Sold price + profit for sold animals
                if (isSold && animal.soldPrice != null) ...[
                  const SizedBox(height: 6),
                  _InfoLine(
                    icon: Icons.price_check,
                    label: 'Sold Price',
                    value: AppUtils.formatCurrency(animal.soldPrice!),
                    valueColor: Colors.blue,
                  ),
                  const SizedBox(height: 6),
                  _InfoLine(
                    icon: Icons.trending_up,
                    label: 'Profit / Loss',
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

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Icon(Icons.pets, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('No animals in this category',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(animalProvider);

    final active   = _filtered(state.animals.where((a) => a.status == 'active').toList());
    final sold     = _filtered(state.animals.where((a) => a.status == 'sold').toList());
    final deceased = _filtered(state.animals.where((a) => a.status == 'deceased').toList());
    final hasFilter = _selectedType != 'All';

    return Scaffold(
      appBar: AppBar(
        title: Text('My Animals (${state.animals.length})'),
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
                Text('Active (${active.length})'),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.circle, size: 8, color: Colors.lightBlueAccent),
                const SizedBox(width: 6),
                Text('Sold (${sold.length})'),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.circle, size: 8, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text('Deceased (${deceased.length})'),
              ]),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Search bar ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search by name, type, or breed…',
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

          // ─── Category filter ───────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _AnimalTypeFilter(
                  value: _selectedType,
                  items: const ['All', ...AppConstants.animalTypes],
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                if (hasFilter) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 14),
                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                    onPressed: () => setState(() => _selectedType = 'All'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ─── Tab body ──────────────────────────────────────────
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
                                style:
                                    const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => ref
                                  .read(animalProvider.notifier)
                                  .loadAnimals(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
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
                            _buildActiveList(active),
                            _buildInactiveList(sold),
                            _buildInactiveList(deceased),
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
        label:
            const Text('Add Animal', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ─── Animal type filter dropdown ─────────────────────────────────────────────
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
    final isActive = value != 'All';
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
              color:
                  isActive ? AppTheme.primaryGreen : Colors.grey),
          const SizedBox(width: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              isDense: true,
              style: TextStyle(
                fontSize: 12,
                color:
                    isActive ? AppTheme.primaryGreen : Colors.black87,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
              ),
              items: items
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Popup menu button widget ────────────────────────────────────────────────
// Clearly visible green button with "⋮" icon; shows on hover and on tap.
class _AnimalMenuButton extends StatefulWidget {
  final VoidCallback onViewDetails;
  final VoidCallback onUpdate;

  const _AnimalMenuButton({
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
        tooltip: 'Options',
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
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility_outlined,
                    color: AppTheme.primaryGreen, size: 20),
                SizedBox(width: 10),
                Text('View Details',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'update',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, color: Colors.orange, size: 20),
                SizedBox(width: 10),
                Text('Update',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info line widget (icon + label + value) ─────────────────────────────────
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
