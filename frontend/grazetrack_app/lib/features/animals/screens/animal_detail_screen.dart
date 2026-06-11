import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/animal_model.dart';
import '../providers/animal_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class AnimalDetailScreen extends ConsumerStatefulWidget {
  final String animalId;
  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  ConsumerState<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends ConsumerState<AnimalDetailScreen> {
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    // Always fetch fresh details from the database when this screen opens.
    Future.microtask(_fetchFresh);
  }

  Future<void> _fetchFresh() async {
    if (!mounted) return;
    setState(() => _fetching = true);
    await ref.read(animalProvider.notifier).fetchAnimalById(widget.animalId);
    if (mounted) setState(() => _fetching = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(animalProvider);
    final animal = state.animals.firstWhere(
      (a) => a.id == widget.animalId,
      orElse: () =>
          const AnimalModel(id: '', userId: '', type: '', purchaseCost: 0),
    );

    // Show spinner while fetching for the first time
    if (_fetching && animal.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Animal Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (animal.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Animal Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Animal not found'),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _fetchFresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Children — animals whose parentId matches this animal's id
    final children =
        state.animals.where((a) => a.parentId == widget.animalId).toList();

    // Parent — if this animal has a parentId
    AnimalModel? parent;
    if (animal.parentId != null && animal.parentId!.isNotEmpty) {
      try {
        parent = state.animals.firstWhere((a) => a.id == animal.parentId);
      } catch (_) {}
    }

    final isActive = animal.status == 'active';
    final statusColor = animal.status == 'sold'
        ? Colors.blue
        : animal.status == 'deceased'
            ? Colors.red
            : AppTheme.primaryGreen;

    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name.isNotEmpty ? animal.name : animal.type),
        actions: [
          // ── Show edit button only for active animals ──────────────
          if (isActive)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Update animal',
              onPressed: () =>
                  context.push('/animals/update/${animal.id}'),
            ),
          // ── Refresh button ────────────────────────────────────────
          IconButton(
            icon: _fetching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetching ? null : _fetchFresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Status Banner ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withAlpha(80)),
              ),
              child: Center(
                child: Text(
                  animal.status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Basic Info Card ───────────────────────────────────
            _SectionCard(
              title: 'Basic Information',
              children: [
                _InfoRow('Name / Tag',
                    animal.name.isNotEmpty ? animal.name : '—'),
                _InfoRow('Type', animal.type),
                _InfoRow('Breed',
                    animal.breed.isNotEmpty ? animal.breed : '—'),
                _InfoRow('Gender',
                    animal.gender.isNotEmpty ? animal.gender : '—'),
                _InfoRow('Current Age', '${animal.currentAge} months'),
                _InfoRow('Weight',
                    animal.weight > 0 ? '${animal.weight} kg' : '—'),
                _InfoRow(
                    'Registered', AppUtils.formatDate(animal.createdAt)),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Financial Info Card ───────────────────────────────
            _SectionCard(
              title: 'Financial Details',
              children: [
                _InfoRow('Purchase Cost',
                    AppUtils.formatCurrency(animal.purchaseCost)),
                if (animal.status == 'sold') ...[
                  _InfoRow('Sold Price',
                      AppUtils.formatCurrency(animal.soldPrice ?? 0)),
                  _InfoRow(
                    'Profit / Loss',
                    AppUtils.profitLabel(
                        (animal.soldPrice ?? 0) - animal.purchaseCost),
                    valueColor: AppUtils.profitColor(
                        (animal.soldPrice ?? 0) - animal.purchaseCost),
                  ),
                  if (animal.soldAt != null)
                    _InfoRow(
                        'Sold On', AppUtils.formatDate(animal.soldAt!)),
                ],
                if (animal.status == 'deceased') ...[
                  if (animal.soldAt != null)
                    _InfoRow('Date of Death',
                        AppUtils.formatDate(animal.soldAt!),
                        valueColor: Colors.red),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // ─── Parent Info ───────────────────────────────────────
            if (parent != null) ...[
              _SectionCard(
                title: 'Parent',
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.backgroundGreen,
                      child: Text(
                        parent.type.isNotEmpty
                            ? parent.type[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppTheme.primaryGreen),
                      ),
                    ),
                    title: Text(parent.name.isNotEmpty
                        ? parent.name
                        : parent.type),
                    subtitle: Text(
                        '${parent.breed} • ${parent.currentAge} months'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push('/animals/${parent!.id}'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ─── Children List ─────────────────────────────────────
            _SectionCard(
              title: 'Offspring (${children.length})',
              children: children.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No offspring recorded',
                            style: TextStyle(color: Colors.grey)),
                      )
                    ]
                  : children
                      .map((child) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.backgroundGreen,
                              child: Text(
                                child.type.isNotEmpty
                                    ? child.type[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppTheme.primaryGreen),
                              ),
                            ),
                            title: Text(child.name.isNotEmpty
                                ? child.name
                                : child.type),
                            subtitle: Text(
                                '${child.breed} • ${child.currentAge} months'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.push('/animals/${child.id}'),
                          ))
                      .toList(),
            ),
            const SizedBox(height: 16),

            // ─── Notes ────────────────────────────────────────────
            if (animal.notes.isNotEmpty) ...[
              _SectionCard(
                title: 'Notes',
                children: [
                  Text(animal.notes,
                      style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Section card wrapper ──────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primaryGreen)),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─── Info row ──────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}
