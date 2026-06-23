import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/animal_provider.dart';
import '../models/animal_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class UpdateAnimalScreen extends ConsumerStatefulWidget {
  final String animalId;
  const UpdateAnimalScreen({super.key, required this.animalId});

  @override
  ConsumerState<UpdateAnimalScreen> createState() => _UpdateAnimalScreenState();
}

class _UpdateAnimalScreenState extends ConsumerState<UpdateAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = AppConstants.animalTypes.first;
  String _selectedGender = 'Male';
  String _selectedStatus = 'active';
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFromAnimal(AnimalModel animal) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = animal.name;
    _breedController.text = animal.breed;
    _ageController.text = animal.age.toString();
    _weightController.text = animal.weight > 0 ? animal.weight.toString() : '';
    _notesController.text = animal.notes;
    _selectedType = AppConstants.animalTypes.contains(animal.type)
        ? animal.type
        : AppConstants.animalTypes.first;
    _selectedGender = (animal.gender == 'Female') ? 'Female' : 'Male';
    _selectedStatus = animal.status;
  }

  Future<void> _submit(AnimalModel animal) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(animalProvider.notifier).updateAnimal(
      animal.id,
      {
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'breed': _breedController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? animal.age,
        'gender': _selectedGender,
        'weight': double.tryParse(_weightController.text) ?? animal.weight,
        'notes': _notesController.text.trim(),
        'status': _selectedStatus,
      },
    );

    setState(() => _isLoading = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      if (success) {
        AppUtils.showSnackBar(context, l10n.animalUpdatedSuccess);
        context.pop();
      } else {
        AppUtils.showSnackBar(context, l10n.animalUpdateFailed, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(animalProvider);
    AnimalModel? animal;
    try {
      animal = state.animals.firstWhere((a) => a.id == widget.animalId);
    } catch (_) {}

    if (animal == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.updateAnimalTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _initFromAnimal(animal);

    final fixedCost = AppUtils.formatCurrency(animal.purchaseCost);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.updateAnimalTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.purchaseCostFixed,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(
                            fixedCost,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                items: [
                  DropdownMenuItem(value: 'Male', child: Text(l10n.male)),
                  DropdownMenuItem(value: 'Female', child: Text(l10n.female)),
                ],
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: l10n.statusLabel,
                  prefixIcon: const Icon(Icons.info_outline),
                ),
                items: [
                  DropdownMenuItem(value: 'active', child: Text(l10n.active)),
                  DropdownMenuItem(value: 'sold', child: Text(l10n.sold)),
                  DropdownMenuItem(
                      value: 'deceased', child: Text(l10n.deceased)),
                ],
                onChanged: (val) => setState(() => _selectedStatus = val!),
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
                        prefixIcon:
                            const Icon(Icons.calendar_today_outlined),
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
                        prefixIcon:
                            const Icon(Icons.monitor_weight_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.healthNotesLabel,
                  hintText: l10n.healthNotesHint,
                  prefixIcon: const Icon(Icons.health_and_safety_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : () => _submit(animal!),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(l10n.saveChanges,
                        style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
