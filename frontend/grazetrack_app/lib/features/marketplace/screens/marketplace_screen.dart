import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() =>
      _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedType = 'All';

  static const _categories = [
    ('All',     '🐾', ''),
    ('Cow',     '🐄', 'Cow'),
    ('Goat',    '🐐', 'Goat'),
    ('Sheep',   '🐑', 'Sheep'),
    ('Pig',     '🐖', 'Pig'),
    ('Chicken', '🐔', 'Chicken'),
    ('Horse',   '🐴', 'Horse'),
    ('Camel',   '🐪', 'Camel'),
    ('Other',   '🐾', 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(marketplaceProvider.notifier).loadListings());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applySearch() {
    ref.read(marketplaceProvider.notifier).loadListings(
          search: _searchCtrl.text.trim(),
          type: _selectedType == 'All' ? '' : _selectedType,
        );
  }

  void _selectCategory(String label, String type) {
    setState(() => _selectedType = label);
    ref.read(marketplaceProvider.notifier).loadListings(
          type: type,
          search: _searchCtrl.text.trim(),
        );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        initialType: _selectedType,
        onApply: (type, minP, maxP, loc) {
          setState(() => _selectedType = type);
          ref.read(marketplaceProvider.notifier).loadListings(
                type: type == 'All' ? '' : type,
                minPrice: minP,
                maxPrice: maxP,
                location: loc,
                search: _searchCtrl.text.trim(),
              );
        },
        onClear: () {
          setState(() {
            _selectedType = 'All';
            _searchCtrl.clear();
          });
          ref.read(marketplaceProvider.notifier).clearFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 60,
            backgroundColor: AppTheme.primaryGreen,
            title: Text(l10n.animalMarketplace,
                style: const TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                tooltip: l10n.advancedFilters,
                onPressed: _showFilterSheet,
              ),
            ],
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () =>
              ref.read(marketplaceProvider.notifier).loadListings(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: l10n.searchAnimalsBreeds,
                            prefixIcon: const Icon(Icons.search,
                                color: AppTheme.primaryGreen),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      _applySearch();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _applySearch(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _applySearch,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.search,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 82,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final (label, emoji, type) = _categories[i];
                      final isSelected = _selectedType == label;
                      return _CategoryTile(
                        emoji: emoji,
                        label: label,
                        selected: isSelected,
                        onTap: () => _selectCategory(label, type),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        _selectedType == 'All'
                            ? l10n.allListingsLabel
                            : _selectedType,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.primaryGreen.withAlpha(60)),
                        ),
                        child: Text(
                          '${state.listings.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (state.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(state.error!),
                        TextButton(
                          onPressed: () => ref
                              .read(marketplaceProvider.notifier)
                              .loadListings(),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state.listings.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storefront_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(l10n.noListingsFound,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey)),
                        Text(l10n.tryDifferentCategory,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _selectedType = 'All');
                            ref
                                .read(marketplaceProvider.notifier)
                                .clearFilters();
                          },
                          icon: const Icon(Icons.clear_all),
                          label: Text(l10n.clearFilters),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ListingCard(listing: state.listings[i]),
                      childCount: state.listings.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/my-listings/create'),
        icon: const Icon(Icons.add),
        label: Text(l10n.sellAnimal),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryGreen
              : Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppTheme.primaryGreen
                : Colors.grey.withAlpha(80),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(listing['images'] ?? []);
    final status = listing['status'] ?? 'available';

    return GestureDetector(
      onTap: () => context.push(
          '/marketplace/${listing['id']}',
          extra: listing),
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: images.isNotEmpty
                      ? Image.network(
                          images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _StatusBadge(status: status),
                ),
                if (listing['verified'] == true)
                  const Positioned(
                    top: 10,
                    left: 10,
                    child: _VerifiedBadge(),
                  ),
                if (images.length > 1)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library_outlined,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 3),
                          Text('${images.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${listing['animalType'] ?? ''} — ${listing['breed'] ?? ''}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        AppUtils.formatCurrency(
                            (listing['price'] ?? 0).toDouble()),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      _InfoChip(
                          icon: Icons.cake_outlined,
                          text: '${listing['age'] ?? 0} months'),
                      if ((listing['weight'] ?? 0) > 0) ...[
                        const SizedBox(width: 8),
                        _InfoChip(
                            icon: Icons.monitor_weight_outlined,
                            text: '${listing['weight']} kg'),
                      ],
                      if ((listing['quantity'] ?? 1) > 1) ...[
                        const SizedBox(width: 8),
                        _InfoChip(
                            icon: Icons.numbers,
                            text: 'Qty: ${listing['quantity']}'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push(
                          '/farmer/${listing['sellerId']}',
                          extra: listing,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  AppTheme.primaryGreen.withAlpha(30),
                              backgroundImage:
                                  (listing['sellerProfileImage'] ?? '')
                                          .isNotEmpty
                                      ? NetworkImage(
                                          listing['sellerProfileImage'])
                                      : null,
                              child: (listing['sellerProfileImage'] ?? '')
                                      .isEmpty
                                  ? Text(
                                      (listing['sellerName'] ?? 'F')
                                          .toString()
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.primaryGreen,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              listing['sellerName'] ?? 'Farmer',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          listing['farmLocation'] ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[200],
        child: const Center(
            child: Icon(Icons.pets, size: 48, color: Colors.grey)),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 3),
          Text(text,
              style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'available':
        color = Colors.green;
        break;
      case 'sold':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(230),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(220),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: Colors.white),
          SizedBox(width: 3),
          Text('Verified',
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String initialType;
  final Function(String type, double? minP, double? maxP, String loc) onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.initialType,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _type;
  final _minPriceCtrl  = TextEditingController();
  final _maxPriceCtrl  = TextEditingController();
  final _locationCtrl  = TextEditingController();

  static const _types = [
    'All', 'Cow', 'Goat', 'Sheep', 'Pig', 'Chicken', 'Horse', 'Camel', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.advancedFilters,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onClear();
                  },
                  child: Text(l10n.clearAll,
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(l10n.animalTypeLabel,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _types.map((t) {
                return ChoiceChip(
                  label: Text(t),
                  selected: _type == t,
                  selectedColor: AppTheme.primaryGreen,
                  labelStyle: TextStyle(
                    color: _type == t ? Colors.white : Colors.black87,
                  ),
                  onSelected: (_) => setState(() => _type = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text(l10n.priceRange,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _minPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: l10n.minPrice,
                      border: const OutlineInputBorder()),
                ),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('—')),
              Expanded(
                child: TextField(
                  controller: _maxPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: l10n.maxPrice,
                      border: const OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            Text(l10n.farmLocationLabel,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationCtrl,
              decoration: InputDecoration(
                hintText: l10n.locationHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onApply(
                    _type,
                    _minPriceCtrl.text.isNotEmpty
                        ? double.tryParse(_minPriceCtrl.text)
                        : null,
                    _maxPriceCtrl.text.isNotEmpty
                        ? double.tryParse(_maxPriceCtrl.text)
                        : null,
                    _locationCtrl.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.applyFilters,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
