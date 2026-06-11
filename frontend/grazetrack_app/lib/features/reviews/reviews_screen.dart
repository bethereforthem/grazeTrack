import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final reviewsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, sellerId) async {
    final api = ApiService();
    final res = await api.get('/reviews/seller/$sellerId');
    final data = res.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  },
);

// ─── Reviews Screen (view seller reviews) ────────────────────────────────────

class ReviewsScreen extends ConsumerWidget {
  final String sellerId;
  final String sellerName;

  const ReviewsScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider(sellerId));

    return Scaffold(
      appBar: AppBar(title: Text('$sellerName — Reviews')),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reviews) {
          if (reviews.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No reviews yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final avgRating = reviews.fold<double>(
                  0, (sum, r) => sum + (r['rating'] ?? 0)) /
              reviews.length;

          return Column(
            children: [
              // ─── Average rating banner ──────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.amber.withAlpha(80)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StarRow(rating: avgRating),
                        Text('${reviews.length} review${reviews.length != 1 ? 's' : ''}',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── Review list ────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reviews.length,
                  itemBuilder: (_, i) => _ReviewCard(review: reviews[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Write Review Screen ──────────────────────────────────────────────────────

class WriteReviewScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> order; // completed order

  const WriteReviewScreen({super.key, required this.order});

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _loading = false;
  final _api = ApiService();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.post('/reviews', {
        'sellerId': widget.order['sellerId'],
        'rating': _rating,
        'comment': _commentCtrl.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Review submitted! Thank you.'),
            backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate the Seller')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Seller avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primaryGreen.withAlpha(30),
              child: Text(
                (widget.order['sellerName'] ?? 'S')[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.order['sellerName'] ?? 'Seller',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Rate your experience with this seller',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // ─── Star selector ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _ratingLabel(_rating),
              style: TextStyle(
                  color: Colors.amber[700], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // ─── Comment ────────────────────────────────────
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                hintText: 'Share your experience with this seller…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),

            // ─── Submit ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.star),
                label: Text(_loading ? 'Submitting…' : 'Submit Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent!';
      default: return '';
    }
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final rating = (review['rating'] ?? 0).toDouble();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryGreen.withAlpha(30),
                  child: Text(
                    (review['reviewerName'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(review['reviewerName'] ?? 'Anonymous',
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                ),
                _StarRow(rating: rating, size: 16),
              ],
            ),
            if ((review['comment'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review['comment'],
                  style: const TextStyle(fontSize: 14, height: 1.4)),
            ],
            const SizedBox(height: 6),
            Text(
              _formatDate(review['createdAt'] ?? ''),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRow({required this.rating, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (i < rating.floor()) {
          icon = Icons.star;
        } else if (i < rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: Colors.amber, size: size);
      }),
    );
  }
}
