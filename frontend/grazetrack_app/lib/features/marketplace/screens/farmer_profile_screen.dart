import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

// ─── Farmer Public Profile Screen ────────────────────────────────────────────
//
// Shows a farmer's public profile:
//   • Their name, location, contact details and optional profile photo
//   • All their active listings in a grid below
//
// Navigation: context.push('/farmer/$sellerId', extra: { ...listingData })
// The `farmerData` extra is optional — if provided it pre-fills the header
// while listings load. If omitted, everything loads from the API.

class FarmerProfileScreen extends StatefulWidget {
  final String sellerId;
  final Map<String, dynamic>? farmerData; // optional pre-filled data from navigation

  const FarmerProfileScreen({
    super.key,
    required this.sellerId,
    this.farmerData,
  });

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final _api = ApiService();

  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;
  String _farmerName   = '';
  String _farmLocation = '';
  String _phone        = '';
  String _email        = '';
  String _profileImage = '';
  bool   _verified     = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill from navigation data if available (instant display)
    if (widget.farmerData != null) {
      final d = widget.farmerData!;
      _farmerName   = d['sellerName']       ?? '';
      _farmLocation = d['farmLocation']     ?? '';
      _phone        = d['contactPhone']     ?? '';
      _email        = d['contactEmail']     ?? '';
      _profileImage = d['sellerProfileImage'] ?? '';
      _verified     = d['verified'] == true;
    }
    _loadProfile();
  }

  // Fetch the farmer's full profile + listings from the public API
  // Uses /api/public/farmers/:sellerId — no login required
  Future<void> _loadProfile() async {
    try {
      final res = await _api.get('/listings',
          params: {'sellerId': widget.sellerId});
      final data = res.data as Map<String, dynamic>;
      final listings =
          List<Map<String, dynamic>>.from(data['data'] ?? []);

      if (listings.isNotEmpty && mounted) {
        final first = listings.first;
        setState(() {
          _farmerName   = first['sellerName']        ?? _farmerName;
          _farmLocation = first['farmLocation']      ?? _farmLocation;
          _phone        = first['contactPhone']      ?? _phone;
          _email        = first['contactEmail']      ?? _email;
          _profileImage = first['sellerProfileImage']?? _profileImage;
          _verified     = first['verified'] == true;
          _listings     = listings;
          _loading      = false;
        });
      } else if (mounted) {
        setState(() { _listings = listings; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Open the phone dialer with the farmer's number
  Future<void> _call() async {
    if (_phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: _phone);
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

  // Open the default email app with the farmer's email pre-filled
  Future<void> _email_() async {
    if (_email.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: _email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Header with gradient background ─────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.lightGreen,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Profile photo (or initials placeholder)
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.white,
                            backgroundImage: _profileImage.isNotEmpty
                                ? NetworkImage(_profileImage)
                                : null,
                            child: _profileImage.isEmpty
                                ? Text(
                                    _farmerName.isNotEmpty
                                        ? _farmerName[0].toUpperCase()
                                        : 'F',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  )
                                : null,
                          ),
                          // Verification badge
                          if (_verified)
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Farmer name
                      Text(
                        _farmerName.isEmpty ? 'Farmer' : _farmerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Location
                      if (_farmLocation.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _farmLocation,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Body ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Contact action buttons ──────────────────────
                if (_phone.isNotEmpty || _email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        if (_phone.isNotEmpty)
                          Expanded(
                            child: _ContactButton(
                              icon: Icons.call,
                              label: 'Call Farmer',
                              color: Colors.green,
                              onTap: _call,
                            ),
                          ),
                        if (_phone.isNotEmpty && _email.isNotEmpty)
                          const SizedBox(width: 12),
                        if (_email.isNotEmpty)
                          Expanded(
                            child: _ContactButton(
                              icon: Icons.email_outlined,
                              label: 'Send Email',
                              color: Colors.blue,
                              onTap: _email_,
                            ),
                          ),
                      ],
                    ),
                  ),

                // ── Stats row ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      _StatPill(
                        label: 'Active Listings',
                        value: '${_listings.length}',
                        icon: Icons.storefront_outlined,
                      ),
                      if (_verified) ...[
                        const SizedBox(width: 12),
                        _StatPill(
                          label: 'Status',
                          value: 'Verified',
                          icon: Icons.verified,
                          color: Colors.blue,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Section title ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    'Animals For Sale',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                // ── Listings ────────────────────────────────────
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_listings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.storefront_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No active listings',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _listings.length,
                    itemBuilder: (_, i) =>
                        _ListingTile(listing: _listings[i]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Button ───────────────────────────────────────────────────────────
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─── Stat Pill ────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatPill(
      {required this.label,
      required this.value,
      required this.icon,
      this.color = AppTheme.primaryGreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style:
                      const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Listing Tile ─────────────────────────────────────────────────────────────
class _ListingTile extends StatelessWidget {
  final Map<String, dynamic> listing;
  const _ListingTile({required this.listing});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(listing['images'] ?? []);
    return GestureDetector(
      onTap: () =>
          context.push('/marketplace/${listing['id']}', extra: listing),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 100,
              height: 100,
              child: images.isNotEmpty
                  ? Image.network(images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${listing['animalType'] ?? ''} — ${listing['breed'] ?? ''}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text('Age: ${listing['age'] ?? 0} months',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    if ((listing['weight'] ?? 0) > 0)
                      Text('Weight: ${listing['weight']} kg',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(
                      AppUtils.formatCurrency(
                          (listing['price'] ?? 0).toDouble()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.pets, size: 36, color: Colors.grey),
      );
}
