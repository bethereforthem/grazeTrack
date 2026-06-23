import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_provider.dart';
import '../models/health_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';

class HealthListScreen extends ConsumerStatefulWidget {
  const HealthListScreen({super.key});

  @override
  ConsumerState<HealthListScreen> createState() => _HealthListScreenState();
}

class _HealthListScreenState extends ConsumerState<HealthListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedAnimalType = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(healthProvider.notifier).loadHealth());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sick':
        return Colors.red;
      case 'critical':
        return Colors.red[900]!;
      case 'recovering':
        return Colors.orange;
      default:
        return AppTheme.primaryGreen;
    }
  }

  List<HealthModel> _filtered(List<HealthModel> all) {
    return all.where((rec) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          rec.type.toLowerCase().contains(q) ||
          rec.vaccination.toLowerCase().contains(q) ||
          rec.description.toLowerCase().contains(q) ||
          rec.vet.toLowerCase().contains(q) ||
          rec.animalType.toLowerCase().contains(q);
      final matchesAnimalType = _selectedAnimalType == 'All' ||
          rec.animalType.toLowerCase() == _selectedAnimalType.toLowerCase();
      final matchesStatus = _selectedStatus == 'All' ||
          rec.status.toLowerCase() == _selectedStatus.toLowerCase();
      return matchesSearch && matchesAnimalType && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthProvider);
    final l10n = AppLocalizations.of(context);
    final filtered = _filtered(state.records);
    final hasFilter = _selectedAnimalType != 'All' || _selectedStatus != 'All';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthRecordsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/health/add'),
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
                hintText: l10n.searchHealthRecords,
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
                  icon: Icons.pets,
                  value: _selectedAnimalType,
                  items: [l10n.all, ...AppConstants.animalTypes],
                  onChanged: (v) => setState(() => _selectedAnimalType = v!),
                ),
                const SizedBox(width: 8),
                _FilterDropdown(
                  icon: Icons.health_and_safety_outlined,
                  value: _selectedStatus,
                  items: [
                    l10n.all,
                    l10n.healthy,
                    l10n.sick,
                    l10n.recovering,
                    l10n.critical,
                  ],
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                ),
                if (hasFilter) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 14),
                    label: Text(l10n.clear,
                        style: const TextStyle(fontSize: 12)),
                    onPressed: () => setState(() {
                      _selectedAnimalType = 'All';
                      _selectedStatus = 'All';
                    }),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filtered.length} record${filtered.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (hasFilter || _searchQuery.isNotEmpty)
                  Text(' — ${l10n.filtered}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.medical_services_outlined,
                                size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              state.records.isEmpty
                                  ? l10n.noHealthRecords
                                  : l10n.noRecordsMatchFilter,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(healthProvider.notifier).loadHealth(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final rec = filtered[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _statusColor(rec.status).withAlpha(30),
                                  child: Icon(Icons.medical_services_outlined,
                                      color: _statusColor(rec.status)),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(rec.type,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    if (rec.animalType.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.backgroundGreen,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          rec.animalType,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.primaryGreen,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                    '${rec.vaccination.isNotEmpty ? rec.vaccination : rec.description}\n'
                                    '${AppUtils.formatDate(rec.date)}'),
                                isThreeLine: true,
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      AppUtils.formatCurrency(rec.cost),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryGreen),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _statusColor(rec.status),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        rec.status.toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 9, color: Colors.white),
                                      ),
                                    ),
                                  ],
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
        onPressed: () => context.push('/health/add'),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.addRecord,
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
    final allLabel = AppLocalizations.of(context).all;
    final isActive = value != 'All' && value != allLabel;
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
