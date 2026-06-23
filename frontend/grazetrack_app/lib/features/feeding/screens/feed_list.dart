import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../models/feed_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';

class FeedListScreen extends ConsumerStatefulWidget {
  const FeedListScreen({super.key});

  @override
  ConsumerState<FeedListScreen> createState() => _FeedListScreenState();
}

class _FeedListScreenState extends ConsumerState<FeedListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFeedType = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(feedProvider.notifier).loadFeed());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FeedModel> _filtered(List<FeedModel> all) {
    return all.where((rec) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          rec.type.toLowerCase().contains(q) ||
          rec.notes.toLowerCase().contains(q);
      final matchesType = _selectedFeedType == 'All' ||
          rec.type.toLowerCase() == _selectedFeedType.toLowerCase();
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);
    final l10n = AppLocalizations.of(context);
    final filtered = _filtered(state.records);
    final totalCost = filtered.fold<double>(0, (s, r) => s + r.cost);
    final hasFilter = _selectedFeedType != 'All';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feedingRecordsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/feed/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                hintText: l10n.searchFeedingRecords,
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterDropdown(
                  icon: Icons.grass,
                  value: _selectedFeedType,
                  items: [l10n.all, ...AppConstants.feedTypes],
                  onChanged: (v) => setState(() => _selectedFeedType = v!),
                ),
                if (hasFilter) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 14),
                    label: Text(l10n.clear,
                        style: const TextStyle(fontSize: 12)),
                    onPressed: () =>
                        setState(() => _selectedFeedType = 'All'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.primaryGreen,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'record' : 'records'}${hasFilter || _searchQuery.isNotEmpty ? ' (${l10n.filtered})' : ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${l10n.total}: ${AppUtils.formatCurrency(totalCost)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.grass, size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              state.records.isEmpty
                                  ? l10n.noFeedingRecords
                                  : l10n.noRecordsMatchFilter,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(feedProvider.notifier).loadFeed(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final rec = filtered[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.backgroundGreen,
                                  child: Icon(Icons.grass,
                                      color: AppTheme.primaryGreen),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(rec.type,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    if (rec.animalCategory.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.backgroundGreen,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          rec.animalCategory,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.primaryGreen,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                    '${rec.quantity} ${rec.unit} • ${AppUtils.formatDate(rec.date)}'
                                    '${rec.notes.isNotEmpty ? '\n${rec.notes}' : ''}'),
                                isThreeLine: rec.notes.isNotEmpty,
                                trailing: Text(
                                  AppUtils.formatCurrency(rec.cost),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGreen),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/feed/add'),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.recordFeed,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.icon,
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
        color: isActive ? AppTheme.primaryGreen.withAlpha(20) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive
                ? AppTheme.primaryGreen.withAlpha(120)
                : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
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
    );
  }
}
