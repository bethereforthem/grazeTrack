import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/animal_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';

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
  String? _selectedParentId; // Item 9: optional parent
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
      if (success) {
        AppUtils.showSnackBar(context, 'Animal added successfully!');
        context.pop();
      } else {
        AppUtils.showSnackBar(context, 'Failed to add animal', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalState = ref.watch(animalProvider);
    // Only active animals can be parents
    final potentialParents =
        animalState.animals.where((a) => a.status == 'active').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Animal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Animal Type
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Animal Type *',
                  prefixIcon: Icon(Icons.pets),
                ),
                items: AppConstants.animalTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 12),

              // Optional name/tag
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name / Tag (optional)',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 12),

              // Breed
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // Gender
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.transgender),
                ),
                items: ['Male', 'Female']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 12),

              // Age and Weight in a row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age (months)',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Purchase Cost
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Purchase Cost *',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Cost is required' : null,
              ),
              const SizedBox(height: 12),

              // Item 9: Optional parent selection
              if (potentialParents.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  initialValue: _selectedParentId,
                  decoration: const InputDecoration(
                    labelText: 'Parent Animal (if born on farm)',
                    prefixIcon: Icon(Icons.family_restroom),
                    helperText: 'Optional — select if this is a born animal',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('— None —')),
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

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes),
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
                    : const Text('Add Animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
