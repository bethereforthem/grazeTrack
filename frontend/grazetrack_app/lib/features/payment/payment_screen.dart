import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final Map<String, dynamic>? order;

  const PaymentScreen({super.key, required this.orderId, this.order});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _api = ApiService();

  // Flow stages: 'form' → 'prompt_sent' → 'confirmed'
  String _stage = 'form';
  String? _paymentId;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  double get _amount =>
      (widget.order?['totalAmount'] ?? 0).toDouble();

  Future<void> _initiatePayment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.post('/payments/initiate', {
        'orderId': widget.orderId,
        'phoneNumber': _phoneCtrl.text.trim(),
      });
      final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      setState(() {
        _paymentId = data['id'] as String;
        _stage = 'prompt_sent';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _confirmPayment() async {
    if (_paymentId == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _api.post('/payments/$_paymentId/confirm', {});
      setState(() { _stage = 'confirmed'; _loading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MoMo Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _stage == 'confirmed'
            ? _SuccessView(amount: _amount, onDone: () => context.go('/orders'))
            : _stage == 'prompt_sent'
                ? _PromptSentView(
                    phone: _phoneCtrl.text,
                    amount: _amount,
                    loading: _loading,
                    error: _error,
                    onConfirm: _confirmPayment,
                    onBack: () => setState(() => _stage = 'form'),
                  )
                : _PaymentForm(
                    formKey: _formKey,
                    phoneCtrl: _phoneCtrl,
                    amount: _amount,
                    order: widget.order,
                    loading: _loading,
                    error: _error,
                    onSubmit: _initiatePayment,
                  ),
      ),
    );
  }
}

// ─── Stage 1: Payment form ────────────────────────────────────────────────────

class _PaymentForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final double amount;
  final Map<String, dynamic>? order;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;

  const _PaymentForm({
    required this.formKey,
    required this.phoneCtrl,
    required this.amount,
    required this.order,
    required this.loading,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // MoMo logo placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.yellow[700],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_android,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Mobile Money Payment',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Pay securely using MoMo',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 28),

          // Amount card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.primaryGreen.withAlpha(180)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Amount to Pay',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  AppUtils.formatCurrency(amount),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                if (order != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${order!['animalType'] ?? ''} — Order #${order!['id']?.toString().substring(0, 8) ?? ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Phone field
          TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'MoMo Phone Number',
              hintText: '024XXXXXXX',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.phone),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Phone number is required';
              if (v.length < 10) return 'Enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withAlpha(80)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A payment prompt will be sent to your phone. Enter your MoMo PIN to confirm.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: loading ? null : onSubmit,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_to_mobile),
              label: Text(
                  loading ? 'Sending prompt…' : 'Send Payment Prompt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stage 2: Prompt sent, waiting for PIN ────────────────────────────────────

class _PromptSentView extends StatelessWidget {
  final String phone;
  final double amount;
  final bool loading;
  final String? error;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  const _PromptSentView({
    required this.phone,
    required this.amount,
    required this.loading,
    required this.error,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.phone_in_talk_outlined,
            size: 72, color: Colors.orange),
        const SizedBox(height: 16),
        const Text('Payment Prompt Sent!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'A MoMo payment prompt of ${AppUtils.formatCurrency(amount)} was sent to $phone.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withAlpha(80)),
          ),
          child: const Column(
            children: [
              Text('Steps to complete:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _Step(n: '1', text: 'Check your phone for the MoMo prompt'),
              _Step(n: '2', text: 'Enter your MoMo PIN to approve'),
              _Step(n: '3', text: 'Come back here and tap "Confirm Payment"'),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(error!,
              style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onConfirm,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check_circle_outline),
            label: Text(loading
                ? 'Confirming…'
                : 'I Have Paid — Confirm Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: loading ? null : onBack,
          child: const Text('← Change Phone Number'),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String n;
  final String text;
  const _Step({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.orange[300],
            child: Text(n,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// ─── Stage 3: Success ─────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final double amount;
  final VoidCallback onDone;

  const _SuccessView({required this.amount, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle_outline,
            color: Colors.green, size: 90),
        const SizedBox(height: 20),
        const Text('Payment Successful!',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 8),
        Text(
          '${AppUtils.formatCurrency(amount)} received',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your order is now paid. The seller will be notified to complete the transaction.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View My Orders',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
