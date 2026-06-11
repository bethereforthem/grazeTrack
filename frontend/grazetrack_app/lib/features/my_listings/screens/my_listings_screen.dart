import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../my_listings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(myListingsProvider.notifier).loadMyListings());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                context.push('/my-listings/create').then((_) =>
                    ref.read(myListingsProvider.notifier).loadMyListings()),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.listings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sell_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No listings yet',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/my-listings/create'),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Listing'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(myListingsProvider.notifier).loadMyListings(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.listings.length,
                    itemBuilder: (_, i) =>
                        _MyListingCard(listing: state.listings[i]),
                  ),
                ),
    );
  }
}

class _MyListingCard extends ConsumerWidget {
  final Map<String, dynamic> listing;
  const _MyListingCard({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = listing['status'] ?? 'available';
    final statusColor = status == 'available'
        ? Colors.green
        : status == 'sold'
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryGreen.withAlpha(30),
          child: const Icon(Icons.pets, color: AppTheme.primaryGreen),
        ),
        title: Text(
          '${listing['animalType'] ?? ''} — ${listing['breed'] ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppUtils.formatCurrency((listing['price'] ?? 0).toDouble()),
              style: TextStyle(
                  color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withAlpha(100)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) async {
            if (val == 'edit') {
              context
                  .push('/my-listings/${listing['id']}/edit', extra: listing)
                  .then((_) => ref
                      .read(myListingsProvider.notifier)
                      .loadMyListings());
            } else if (val == 'delete') {
              final confirm = await AppUtils.showConfirmDialog(
                context,
                title: 'Delete Listing',
                message:
                    'Are you sure you want to delete this listing? This cannot be undone.',
                confirmText: 'Delete',
              );
              if (confirm) {
                final ok = await ref
                    .read(myListingsProvider.notifier)
                    .deleteListing(listing['id']);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete listing')),
                  );
                }
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 8),
                Text('Edit'),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ]),
            ),
          ],
        ),
        onTap: () => context.push('/marketplace/${listing['id']}',
            extra: listing),
      ),
    );
  }
}
