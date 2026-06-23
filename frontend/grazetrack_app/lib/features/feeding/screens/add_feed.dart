import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

class AddFeedScreen extends ConsumerStatefulWidget {
  const AddFeedScreen({super.key});

  @override
  ConsumerState<AddFeedScreen> createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends ConsumerState<AddFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedAnimalCategory = AppConstants.animalTypes.first;
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = AppConstants.feedTypes.first;
  String _selectedUnit = AppConstants.feedUnits.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(feedProvider.notifier).createFeed({
      'animalCategory': _selectedAnimalCategory,
      'type': _selectedType,
      'quantity': double.tryParse(_quantityController.text) ?? 0,
      'unit': _selectedUnit,
      'cost': double.tryParse(_costController.text) ?? 0,
      'notes': _notesController.text.trim(),
      'date': DateTime.now().toIso8601String(),
    });

    setState(() => _isLoading = false);
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      if (success) {
        AppUtils.showSnackBar(context, l10n.feedRecordAdded);
        context.pop();
      } else {
        AppUtils.showSnackBar(context, l10n.feedRecordFailed, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordFeedingTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedAnimalCategory,
                decoration: InputDecoration(
                  labelText: l10n.animalCategoryRequired,
                  prefixIcon: const Icon(Icons.pets),
                ),
                items: AppConstants.animalTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedAnimalCategory = val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.feedTypeRequired,
                  prefixIcon: const Icon(Icons.grass),
                ),
                items: AppConstants.feedTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.quantityRequired,
                        prefixIcon: const Icon(Icons.scale),
                      ),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? l10n.required : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: InputDecoration(labelText: l10n.unit),
                      items: AppConstants.feedUnits
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedUnit = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.costWithSymbol,
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? l10n.costFieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.notesOptional,
                  prefixIcon: const Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l10n.saveFeedRecord),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
