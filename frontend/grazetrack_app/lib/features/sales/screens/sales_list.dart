import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/sales_provider.dart';
import '../models/sale_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';

class SalesListScreen extends ConsumerStatefulWidget {
  const SalesListScreen({super.key});

  @override
  ConsumerState<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends ConsumerState<SalesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedAnimalType = 'All';
  String _selectedResult = 'All'; // All / Profit / Loss

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(salesProvider.notifier).loadSales());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SaleModel> _filtered(List<SaleModel> all) {
    return all.where((sale) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          sale.animalType.toLowerCase().contains(q) ||
          sale.animalBreed.toLowerCase().contains(q) ||
          sale.buyerName.toLowerCase().contains(q) ||
          sale.notes.toLowerCase().contains(q);

      final matchesType = _selectedAnimalType == 'All' ||
          sale.animalType.toLowerCase() ==
              _selectedAnimalType.toLowerCase();

      final matchesResult = _selectedResult == 'All' ||
          (_selectedResult == 'Profit' && sale.isProfit) ||
          (_selectedResult == 'Loss' && !sale.isProfit);

      return matchesSearch && matchesType && matchesResult;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesProvider);
    final filtered = _filtered(state.sales);
    final totalProfit =
        filtered.fold<double>(0, (s, e) => s + e.profit);
    final hasFilter =
        _selectedAnimalType != 'All' || _selectedResult != 'All';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/sales/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search by animal, breed, buyer…',
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

          // ─── Filter chips ────────────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // Animal type filter
                _FilterDropdown(
                  icon: Icons.pets,
                  value: _selectedAnimalType,
                  items: const ['All', ...AppConstants.animalTypes],
                  onChanged: (v) =>
                      setState(() => _selectedAnimalType = v!),
                ),
                const SizedBox(width: 8),
                // Profit / Loss filter
                _FilterDropdown(
                  icon: Icons.trending_up,
                  value: _selectedResult,
                  items: const ['All', 'Profit', 'Loss'],
                  onChanged: (v) =>
                      setState(() => _selectedResult = v!),
                ),
                if (hasFilter) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 14),
                    label: const Text('Clear',
                        style: TextStyle(fontSize: 12)),
                    onPressed: () => setState(() {
                      _selectedAnimalType = 'All';
                      _selectedResult = 'All';
                    }),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ─── Profit / Loss summary banner ────────────────────────
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: totalProfit >= 0
                ? AppTheme.primaryGreen
                : AppTheme.lossRed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} sale${filtered.length == 1 ? '' : 's'}${hasFilter || _searchQuery.isNotEmpty ? ' (filtered)' : ''}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalProfit >= 0 ? 'Total Profit' : 'Total Loss',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      AppUtils.formatCurrency(totalProfit.abs()),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Sales list ──────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sell_outlined,
                                size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              state.sales.isEmpty
                                  ? 'No sales yet'
                                  : 'No sales match your filters',
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(salesProvider.notifier).loadSales(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final sale = filtered[i];
                            return Card(
                              margin:
                                  const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${sale.animalType} ${sale.animalBreed}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                          decoration: BoxDecoration(
                                            color: sale.isProfit
                                                ? AppTheme.profitGreen
                                                : AppTheme.lossRed,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            sale.isProfit
                                                ? 'PROFIT'
                                                : 'LOSS',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _InfoChip(
                                            'Sold for',
                                            AppUtils.formatCurrency(
                                                sale.sellingPrice)),
                                        const SizedBox(width: 12),
                                        _InfoChip(
                                            'Cost',
                                            AppUtils.formatCurrency(
                                                sale.totalCost)),
                                        const SizedBox(width: 12),
                                        _InfoChip(
                                          sale.isProfit
                                              ? 'Profit'
                                              : 'Loss',
                                          AppUtils.formatCurrency(
                                              sale.profit.abs()),
                                          color: sale.isProfit
                                              ? AppTheme.profitGreen
                                              : AppTheme.lossRed,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ROI: ${sale.roi.toStringAsFixed(1)}% • ${AppUtils.formatDate(sale.date)}'
                                      '${sale.buyerName.isNotEmpty ? ' • ${sale.buyerName}' : ''}',
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12),
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
        onPressed: () => context.push('/sales/add'),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.sell_outlined, color: Colors.white),
        label: const Text('Record Sale',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ─── Reusable compact filter dropdown ────────────────────────────────────────
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          isDense: true,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppTheme.primaryGreen : Colors.black87,
            fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
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

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _InfoChip(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color ?? Colors.black87)),
      ],
    );
  }
}
