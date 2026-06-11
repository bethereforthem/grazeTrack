import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../orders_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _filterStatus = 'All';
  static const _statuses = ['All', 'Pending', 'Approved', 'Completed', 'Rejected'];

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(ordersProvider.notifier).loadAdminOrders());
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> all) {
    if (_filterStatus == 'All') return all;
    return all.where((o) => o['status'] == _filterStatus).toList();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Approved': return Colors.blue;
      case 'Completed': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);
    final filtered = _filtered(state.adminOrders);

    // Summary counts
    final pending = state.adminOrders.where((o) => o['status'] == 'Pending').length;
    final approved = state.adminOrders.where((o) => o['status'] == 'Approved').length;
    final completed = state.adminOrders.where((o) => o['status'] == 'Completed').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(ordersProvider.notifier).loadAdminOrders(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ─── Summary cards ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _SummaryCard('Pending', pending, Colors.orange),
                      const SizedBox(width: 8),
                      _SummaryCard('Approved', approved, Colors.blue),
                      const SizedBox(width: 8),
                      _SummaryCard('Completed', completed, Colors.green),
                    ],
                  ),
                ),

                // ─── Status filter chips ─────────────────────────
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: _statuses.map((s) {
                      final selected = _filterStatus == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s),
                          selected: selected,
                          selectedColor: AppTheme.primaryGreen,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                          ),
                          onSelected: (_) =>
                              setState(() => _filterStatus = s),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // ─── Orders list ────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No orders found',
                              style: TextStyle(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(ordersProvider.notifier)
                              .loadAdminOrders(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => _AdminOrderCard(
                              order: filtered[i],
                              statusColor: _statusColor(
                                  filtered[i]['status'] ?? 'Pending'),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryCard(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _AdminOrderCard extends ConsumerWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  const _AdminOrderCard({required this.order, required this.statusColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = order['status'] ?? 'Pending';
    final payStatus = order['paymentStatus'] ?? 'Unpaid';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order['animalType'] ?? ''} — ${order['breed'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withAlpha(100)),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Buyer: ${order['buyerName'] ?? ''}',
                style: const TextStyle(fontSize: 13)),
            Text('Seller: ${order['sellerName'] ?? ''}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  AppUtils.formatCurrency(
                      (order['totalAmount'] ?? 0).toDouble()),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen),
                ),
                const Spacer(),
                Icon(
                  payStatus == 'Paid'
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  color: payStatus == 'Paid' ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(payStatus,
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            payStatus == 'Paid' ? Colors.green : Colors.red)),
              ],
            ),

            // ─── Action buttons ───────────────────────────────
            if (status == 'Pending') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final ok = await ref
                            .read(ordersProvider.notifier)
                            .updateStatus(order['id'], 'Rejected');
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    ref.read(ordersProvider).error ??
                                        'Failed')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red)),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await ref
                            .read(ordersProvider.notifier)
                            .updateStatus(order['id'], 'Approved');
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    ref.read(ordersProvider).error ??
                                        'Failed')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
            if (status == 'Approved' && payStatus == 'Paid') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await ref
                        .read(ordersProvider.notifier)
                        .updateStatus(order['id'], 'Completed');
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(ref.read(ordersProvider).error ??
                                'Failed')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  child: const Text('Mark Completed'),
                ),
              ),
            ],

            TextButton(
              onPressed: () =>
                  context.push('/orders/${order['id']}', extra: order),
              child: const Text('View Details →'),
            ),
          ],
        ),
      ),
    );
  }
}
