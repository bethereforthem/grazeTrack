import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/expense_provider.dart';
import '../models/expense_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(expenseProvider.notifier).loadExpenses());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'feed':
        return Icons.grass;
      case 'medicine':
        return Icons.medication_outlined;
      case 'labor':
        return Icons.people_outlined;
      case 'equipment':
        return Icons.construction_outlined;
      case 'transport':
        return Icons.local_shipping_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  List<ExpenseModel> _filtered(List<ExpenseModel> all) {
    return all.where((exp) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          exp.type.toLowerCase().contains(q) ||
          exp.description.toLowerCase().contains(q);
      final matchesType = _selectedType == 'All' ||
          exp.type.toLowerCase() == _selectedType.toLowerCase();
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseProvider);
    final l10n = AppLocalizations.of(context);
    final filtered = _filtered(state.expenses);
    final total = filtered.fold<double>(0, (s, e) => s + e.amount);
    final hasFilter = _selectedType != 'All';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expensesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/expenses/add'),
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
                hintText: l10n.searchExpenses,
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
                  icon: Icons.category_outlined,
                  value: _selectedType,
                  items: [l10n.all, ...AppConstants.expenseTypes],
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.primaryGreen,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} expense${filtered.length == 1 ? '' : 's'}${hasFilter || _searchQuery.isNotEmpty ? ' (${l10n.filtered})' : ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  AppUtils.formatCurrency(total),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
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
                            const Icon(Icons.receipt_long,
                                size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              state.expenses.isEmpty
                                  ? l10n.noExpensesRecorded
                                  : l10n.noExpensesMatchFilter,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(expenseProvider.notifier)
                            .loadExpenses(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final exp = filtered[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.backgroundGreen,
                                  child: Icon(_typeIcon(exp.type),
                                      color: AppTheme.primaryGreen),
                                ),
                                title: Text(exp.type,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    '${exp.description}\n${AppUtils.formatDate(exp.date)}'),
                                isThreeLine: true,
                                trailing: Text(
                                  AppUtils.formatCurrency(exp.amount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.warningOrange,
                                      fontSize: 15),
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
        onPressed: () => context.push('/expenses/add'),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.addExpense,
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
