import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../orders_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(ordersProvider.notifier).loadMyOrders(perspective: 'buyer');
    });
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      if (_tabs.index == 0) {
        ref.read(ordersProvider.notifier).loadMyOrders(perspective: 'buyer');
      } else {
        ref.read(ordersProvider.notifier).loadMyOrders(perspective: 'seller');
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ordersTitle),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.asBuyer),
            Tab(text: l10n.asSeller),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _OrderList(
                  orders: state.orders,
                  onRefresh: () => ref
                      .read(ordersProvider.notifier)
                      .loadMyOrders(perspective: 'buyer'),
                ),
                _OrderList(
                  orders: state.orders,
                  onRefresh: () => ref
                      .read(ordersProvider.notifier)
                      .loadMyOrders(perspective: 'seller'),
                  isSeller: true,
                ),
              ],
            ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Future<void> Function() onRefresh;
  final bool isSeller;

  const _OrderList({
    required this.orders,
    required this.onRefresh,
    this.isSeller = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              isSeller ? l10n.noOrdersOnListings : l10n.noOrders,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (!isSeller) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => context.go('/marketplace'),
                icon: const Icon(Icons.storefront_outlined),
                label: Text(l10n.browseMarketplace),
              ),
            ],
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (_, i) =>
            _OrderCard(order: orders[i], isSeller: isSeller),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isSeller;

  const _OrderCard({required this.order, this.isSeller = false});

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = order['status'] ?? 'Pending';
    final payStatus = order['paymentStatus'] ?? 'Unpaid';
    final color = _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/orders/${order['id']}', extra: order),
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
                  _Badge(label: status, color: color),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isSeller
                    ? '${l10n.buyerLabel}: ${order['buyerName'] ?? ''}'
                    : '${l10n.sellerLabel}: ${order['sellerName'] ?? ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    AppUtils.formatCurrency(
                        (order['totalAmount'] ?? 0).toDouble()),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                        fontSize: 15),
                  ),
                  const Spacer(),
                  _Badge(
                    label: payStatus,
                    color: payStatus == 'Paid' ? Colors.green : Colors.red,
                  ),
                ],
              ),
              if (!isSeller &&
                  status == 'Approved' &&
                  payStatus == 'Unpaid') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.push('/payment/${order['id']}', extra: order),
                    icon: const Icon(Icons.payment, size: 18),
                    label: Text(l10n.payNowViaMoMo),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
