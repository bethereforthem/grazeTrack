import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/animal_model.dart';
import '../providers/animal_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final animal = state.animals.firstWhere(
      (a) => a.id == widget.animalId,
      orElse: () =>
          const AnimalModel(id: '', userId: '', type: '', purchaseCost: 0),
    );

    if (_fetching && animal.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.animalDetailsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (animal.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.animalDetailsTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(l10n.animalNotFound),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _fetchFresh,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final children =
        state.animals.where((a) => a.parentId == widget.animalId).toList();

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
          if (isActive)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  context.push('/animals/update/${animal.id}'),
            ),
          IconButton(
            icon: _fetching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _fetching ? null : _fetchFresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            _SectionCard(
              title: l10n.basicInformation,
              children: [
                _InfoRow(l10n.nameTagOptional,
                    animal.name.isNotEmpty ? animal.name : '—'),
                _InfoRow(l10n.animalTypeRequired, animal.type),
                _InfoRow(l10n.breed,
                    animal.breed.isNotEmpty ? animal.breed : '—'),
                _InfoRow(l10n.gender,
                    animal.gender.isNotEmpty ? animal.gender : '—'),
                _InfoRow(l10n.ageMonths, '${animal.currentAge} ${l10n.months}'),
                _InfoRow(l10n.weightKg,
                    animal.weight > 0 ? '${animal.weight} kg' : '—'),
                _InfoRow(l10n.registeredLabel,
                    AppUtils.formatDate(animal.createdAt)),
              ],
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: l10n.financialDetailsSection,
              children: [
                _InfoRow(l10n.purchaseCost,
                    AppUtils.formatCurrency(animal.purchaseCost)),
                if (animal.status == 'sold') ...[
                  _InfoRow(l10n.soldPrice,
                      AppUtils.formatCurrency(animal.soldPrice ?? 0)),
                  _InfoRow(
                    l10n.profitLoss,
                    AppUtils.profitLabel(
                        (animal.soldPrice ?? 0) - animal.purchaseCost),
                    valueColor: AppUtils.profitColor(
                        (animal.soldPrice ?? 0) - animal.purchaseCost),
                  ),
                  if (animal.soldAt != null)
                    _InfoRow(l10n.soldOnLabel,
                        AppUtils.formatDate(animal.soldAt!)),
                ],
                if (animal.status == 'deceased') ...[
                  if (animal.soldAt != null)
                    _InfoRow(l10n.dateOfDeath,
                        AppUtils.formatDate(animal.soldAt!),
                        valueColor: Colors.red),
                ],
              ],
            ),
            const SizedBox(height: 16),

            if (parent != null) ...[
              _SectionCard(
                title: l10n.parentLabel,
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
                        '${parent.breed} • ${parent.currentAge} ${l10n.months}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push('/animals/${parent!.id}'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            _SectionCard(
              title: l10n.offspringSection(children.length),
              children: children.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(l10n.noOffspringRecorded,
                            style: const TextStyle(color: Colors.grey)),
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
                                '${child.breed} • ${child.currentAge} ${l10n.months}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.push('/animals/${child.id}'),
                          ))
                      .toList(),
            ),
            const SizedBox(height: 16),

            if (animal.notes.isNotEmpty) ...[
              _SectionCard(
                title: l10n.notesOptional,
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
