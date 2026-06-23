import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/animal_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

class AddAnimalScreen extends ConsumerStatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  ConsumerState<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends ConsumerState<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = AppConstants.animalTypes.first;
  String _selectedGender = 'Male';
  String? _selectedParentId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'breed': _breedController.text.trim(),
      'age': int.tryParse(_ageController.text) ?? 0,
      'gender': _selectedGender,
      'weight': double.tryParse(_weightController.text) ?? 0,
      'purchaseCost': double.tryParse(_costController.text) ?? 0,
      'notes': _notesController.text.trim(),
      'date': DateTime.now().toIso8601String(),
      if (_selectedParentId != null) 'parentId': _selectedParentId,
    };

    final success = await ref.read(animalProvider.notifier).createAnimal(data);
    setState(() => _isLoading = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      if (success) {
        AppUtils.showSnackBar(context, l10n.animalAddedSuccess);
        context.pop();
      } else {
        AppUtils.showSnackBar(context, l10n.animalAddFailed, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalState = ref.watch(animalProvider);
    final l10n = AppLocalizations.of(context);
    final potentialParents =
        animalState.animals.where((a) => a.status == 'active').toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addAnimal)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.animalTypeRequired,
                  prefixIcon: const Icon(Icons.pets),
                ),
                items: AppConstants.animalTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.nameTagOptional,
                  prefixIcon: const Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: l10n.breed,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: l10n.gender,
                  prefixIcon: const Icon(Icons.transgender),
                ),
                items: [l10n.male, l10n.female]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.ageMonths,
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.weightKg,
                        prefixIcon: const Icon(Icons.monitor_weight_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.purchaseCostRequired,
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? l10n.costRequired : null,
              ),
              const SizedBox(height: 12),
              if (potentialParents.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  initialValue: _selectedParentId,
                  decoration: InputDecoration(
                    labelText: l10n.parentAnimal,
                    prefixIcon: const Icon(Icons.family_restroom),
                    helperText: l10n.parentAnimalHelper,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                        value: null, child: Text(l10n.noneOption)),
                    ...potentialParents.map((a) => DropdownMenuItem<String?>(
                          value: a.id,
                          child: Text(
                            '${a.name.isNotEmpty ? a.name : a.type} (${a.breed}, ${a.currentAge}mo)',
                          ),
                        )),
                  ],
                  onChanged: (val) =>
                      setState(() => _selectedParentId = val),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _notesController,
                maxLines: 3,
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
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(l10n.addAnimal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
