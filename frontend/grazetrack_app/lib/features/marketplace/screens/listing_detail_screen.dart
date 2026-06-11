import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../chat/chat_provider.dart';

// ─── Listing Detail Screen ────────────────────────────────────────────────────
//
// Shows full details of a marketplace listing:
//   • Photo gallery (swipeable)
//   • Price, type, breed, age, weight, quantity
//   • Seller info with profile photo + verified badge
//   • "Call Farmer" button — opens phone dialer
//   • "Message Seller" button — opens in-app chat
//   • "Place Order" button — starts purchase flow
//
// If the user IS the seller, they see "Edit Listing" instead.

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;
  final Map<String, dynamic>? listing; // optional pre-loaded data

  const ListingDetailScreen({
    super.key,
    required this.listingId,
    this.listing,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState
    extends ConsumerState<ListingDetailScreen> {
  final _api = ApiService();

  Map<String, dynamic>? _listing;
  bool _loading    = true;
  bool _chatLoading = false;
  String? _currentUserId;
  int _imageIndex  = 0;

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;
    if (_listing != null) _loading = false;
    _loadUser();
    if (_listing == null) _fetchListing();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) setState(() => _currentUserId = user?['id']);
  }

  Future<void> _fetchListing() async {
    try {
      final res = await _api.get('/listings/${widget.listingId}');
      final data = (res.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      if (mounted) setState(() { _listing = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Open in-app chat with the seller
  Future<void> _startChat() async {
    if (_listing == null) return;
    setState(() => _chatLoading = true);
    final threadId = await ref.read(chatProvider.notifier).getOrCreateThread(
      _listing!['sellerId'],
      listingId: _listing!['id'],
    );
    if (!mounted) return;
    setState(() => _chatLoading = false);
    if (threadId != null) {
      context.push('/chat/thread/$threadId', extra: {
        'sellerName': _listing!['sellerName'],
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not open chat. Please try again.')),
      );
    }
  }

  // Open the phone dialer with the farmer's contact number
  Future<void> _callFarmer() async {
    final phone = _listing?['contactPhone'] ?? '';
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer')),
        );
      }
    }
  }

  bool get _isOwner =>
      _currentUserId != null &&
      _listing != null &&
      _listing!['sellerId'] == _currentUserId;

  // Format "days ago" from ISO date string
  String _timeAgo(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
      return '${(diff.inDays / 30).floor()} months ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Listing not found')),
      );
    }

    final images  = List<String>.from(_listing!['images'] ?? []);
    final status  = _listing!['status'] ?? 'available';
    final phone   = _listing!['contactPhone'] ?? '';
    final posted  = _timeAgo(_listing!['createdAt']);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Image Gallery App Bar ───────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (i) =>
                          setState(() => _imageIndex = i),
                      itemBuilder: (_, i) => Image.network(
                        images[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder(),
                      ),
                    )
                  : _imgPlaceholder(),
            ),
          ),

          // ─── Detail Content ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image dots indicator
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _imageIndex ? 16 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _imageIndex
                                  ? AppTheme.primaryGreen
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── Title, Status, Price ─────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${_listing!['animalType']} — ${_listing!['breed'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      _StatusChip(status: status),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Date posted
                  if (posted.isNotEmpty)
                    Text('Posted $posted',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    AppUtils.formatCurrency(
                        (_listing!['price'] ?? 0).toDouble()),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Info Grid ────────────────────────────
                  _InfoGrid(listing: _listing!),
                  const SizedBox(height: 16),

                  // ── Description ──────────────────────────
                  if ((_listing!['description'] ?? '').toString().isNotEmpty)
                    _Section(
                      title: 'Description',
                      child: Text(
                        _listing!['description'],
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5),
                      ),
                    ),

                  // ── Seller Card ───────────────────────────
                  _Section(
                    title: 'Seller Information',
                    child: GestureDetector(
                      // Tapping the seller card opens their public profile
                      onTap: () => context.push(
                        '/farmer/${_listing!['sellerId']}',
                        extra: _listing,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withAlpha(10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color:
                                  AppTheme.primaryGreen.withAlpha(40)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Seller profile photo
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor:
                                          AppTheme.primaryGreen
                                              .withAlpha(30),
                                      backgroundImage:
                                          (_listing!['sellerProfileImage'] ??
                                                      '')
                                                  .isNotEmpty
                                              ? NetworkImage(_listing![
                                                  'sellerProfileImage'])
                                              : null,
                                      child: (_listing![
                                                      'sellerProfileImage'] ??
                                                  '')
                                              .isEmpty
                                          ? Text(
                                              (_listing!['sellerName'] ??
                                                      'F')
                                                  .toString()
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  color: AppTheme
                                                      .primaryGreen,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            )
                                          : null,
                                    ),
                                    // Verified badge on avatar
                                    if (_listing!['verified'] == true)
                                      const Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Icon(Icons.verified,
                                            color: Colors.blue,
                                            size: 18),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Text(
                                          _listing!['sellerName'] ??
                                              'Unknown',
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        if (_listing!['verified'] == true) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified,
                                              color: Colors.blue,
                                              size: 14),
                                        ],
                                      ]),
                                      if ((_listing!['farmLocation'] ??
                                              '')
                                          .isNotEmpty)
                                        Row(children: [
                                          const Icon(
                                              Icons.location_on_outlined,
                                              size: 13,
                                              color: Colors.grey),
                                          const SizedBox(width: 2),
                                          Text(
                                            _listing!['farmLocation'],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ]),
                                      if (phone.isNotEmpty)
                                        Row(children: [
                                          const Icon(
                                              Icons.phone_outlined,
                                              size: 13,
                                              color: Colors.grey),
                                          const SizedBox(width: 2),
                                          Text(phone,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ]),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80), // space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // ─── Bottom Action Bar ───────────────────────────────
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: status == 'available' && !_isOwner
            ? Row(
                children: [
                  // Call Farmer button
                  if (phone.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: _callFarmer,
                      icon: const Icon(Icons.call,
                          color: AppTheme.primaryGreen),
                      label: const Text('Call',
                          style: TextStyle(
                              color: AppTheme.primaryGreen)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        side: const BorderSide(
                            color: AppTheme.primaryGreen),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  if (phone.isNotEmpty) const SizedBox(width: 8),

                  // Message Seller (opens in-app chat)
                  OutlinedButton.icon(
                    onPressed: _chatLoading ? null : _startChat,
                    icon: _chatLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : const Icon(Icons.chat_bubble_outline),
                    label: Text(_chatLoading ? '…' : 'Chat'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Place Order
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/orders/place', extra: _listing),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Place Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              )
            : _isOwner
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(
                          '/my-listings/${_listing!['id']}/edit',
                          extra: _listing),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Listing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                : null,
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        color: Colors.grey[200],
        child: const Center(
            child: Icon(Icons.pets, size: 80, color: Colors.grey)),
      );
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'available' ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color)),
    );
  }
}

// Info grid: Type, Breed, Age, Weight, Quantity
class _InfoGrid extends StatelessWidget {
  final Map<String, dynamic> listing;
  const _InfoGrid({required this.listing});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData)>[
      ('Type',     listing['animalType'] ?? '-',          Icons.category_outlined),
      ('Breed',    listing['breed'] ?? '-',               Icons.pets),
      ('Age',      '${listing['age'] ?? 0} months',       Icons.cake_outlined),
      ('Quantity', '${listing['quantity'] ?? 1} head',    Icons.numbers),
      if ((listing['weight'] ?? 0) > 0)
        ('Weight', '${listing['weight']} kg',             Icons.monitor_weight_outlined),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withAlpha(10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(item.$3, size: 16, color: AppTheme.primaryGreen),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.$1,
                      style: const TextStyle(
                          fontSize: 10, color: Colors.grey)),
                  Text(item.$2,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}
