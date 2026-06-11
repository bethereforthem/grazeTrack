import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic>? order;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.order,
  });

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
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final o = order!;
    final status = o['status'] ?? 'Pending';
    final payStatus = o['paymentStatus'] ?? 'Unpaid';
    final statusColor = _statusColor(status);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Status banner ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: statusColor.withAlpha(80)),
              ),
              child: Column(
                children: [
                  Icon(_statusIcon(status), color: statusColor, size: 40),
                  const SizedBox(height: 8),
                  Text(status,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                  Text(_statusMessage(status, payStatus),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Animal details ─────────────────────────────────
            _Section(
              title: 'Animal',
              rows: [
                ('Type', '${o['animalType'] ?? ''} — ${o['breed'] ?? ''}'),
                ('Quantity', '${o['quantity'] ?? 1}'),
                ('Price/unit', AppUtils.formatCurrency((o['pricePerUnit'] ?? 0).toDouble())),
                ('Total Amount', AppUtils.formatCurrency((o['totalAmount'] ?? 0).toDouble())),
              ],
              highlighted: true,
            ),

            // ─── Buyer details ──────────────────────────────────
            _Section(
              title: 'Buyer',
              rows: [
                ('Name', o['buyerName'] ?? '-'),
                ('Phone', o['buyerPhone'] ?? '-'),
                ('Address', o['buyerAddress'] ?? '-'),
              ],
            ),

            // ─── Seller details ─────────────────────────────────
            _Section(
              title: 'Seller',
              rows: [
                ('Name', o['sellerName'] ?? '-'),
              ],
            ),

            // ─── Payment ────────────────────────────────────────
            _Section(
              title: 'Payment',
              rows: [
                ('Status', payStatus),
              ],
            ),

            if ((o['notes'] ?? '').toString().isNotEmpty)
              _Section(
                title: 'Notes',
                rows: [('', o['notes'])],
              ),

            const SizedBox(height: 16),

            // ─── Actions ────────────────────────────────────────
            if (status == 'Approved' && payStatus == 'Unpaid')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/payment/${o['id']}', extra: o),
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay via MoMo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            if (status == 'Completed') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/reviews/write', extra: o),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Rate the Seller'),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'Approved': return Icons.thumb_up_outlined;
      case 'Completed': return Icons.check_circle_outline;
      case 'Rejected': return Icons.cancel_outlined;
      default: return Icons.hourglass_empty;
    }
  }

  String _statusMessage(String status, String payStatus) {
    switch (status) {
      case 'Pending': return 'Waiting for seller approval';
      case 'Approved':
        return payStatus == 'Paid'
            ? 'Payment received. Waiting for completion.'
            : 'Approved! Please complete your payment.';
      case 'Completed': return 'Order successfully completed!';
      case 'Rejected': return 'This order was rejected by the seller.';
      default: return '';
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<(String, dynamic)> rows;
  final bool highlighted;

  const _Section({
    required this.title,
    required this.rows,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: highlighted
                ? AppTheme.primaryGreen.withAlpha(15)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: highlighted
                    ? AppTheme.primaryGreen.withAlpha(60)
                    : Colors.grey.withAlpha(50)),
          ),
          child: Column(
            children: rows.map((row) {
              if (row.$1.isEmpty) {
                return Text(row.$2.toString(),
                    style: const TextStyle(fontSize: 14));
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(row.$1,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(
                        row.$2?.toString() ?? '-',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
