import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_provider.dart';
import '../../animals/providers/animal_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';

class AddHealthScreen extends ConsumerStatefulWidget {
  const AddHealthScreen({super.key});

  @override
  ConsumerState<AddHealthScreen> createState() => _AddHealthScreenState();
}

class _AddHealthScreenState extends ConsumerState<AddHealthScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAnimalId;
  final _vaccinationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _medicineController = TextEditingController();
  final _costController = TextEditingController();
  final _vetController = TextEditingController();
  String _selectedType = AppConstants.healthTypes.first;
  String _selectedStatus = AppConstants.healthStatuses.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(animalProvider.notifier).loadAnimals());
  }

  @override
  void dispose() {
    _vaccinationController.dispose();
    _descriptionController.dispose();
    _medicineController.dispose();
    _costController.dispose();
    _vetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(healthProvider.notifier).createHealth({
      'animalId': _selectedAnimalId ?? '',
      'type': _selectedType,
      'vaccination': _vaccinationController.text.trim(),
      'status': _selectedStatus,
      'description': _descriptionController.text.trim(),
      'medicine': _medicineController.text.trim(),
      'cost': double.tryParse(_costController.text) ?? 0,
      'vet': _vetController.text.trim(),
      'date': DateTime.now().toIso8601String(),
    });

    setState(() => _isLoading = false);
    if (mounted) {
      if (success) {
        AppUtils.showSnackBar(context, 'Health record added!');
        context.pop();
      } else {
        AppUtils.showSnackBar(context, 'Failed to save record', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalState = ref.watch(animalProvider);
    final activeAnimals = animalState.animals
        .where((a) => a.status == 'active')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Health Record')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (animalState.isLoading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedAnimalId,
                  decoration: const InputDecoration(
                    labelText: 'Select Animal *',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  hint: const Text('Choose an animal'),
                  items: activeAnimals.map((a) {
                    final label = a.name.isNotEmpty
                        ? '${a.name} (${a.type})'
                        : a.type;
                    return DropdownMenuItem(value: a.id, child: Text(label));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAnimalId = val),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Please select an animal' : null,
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Record Type *',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                items: AppConstants.healthTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Health Status *',
                  prefixIcon: Icon(Icons.health_and_safety_outlined),
                ),
                items: AppConstants.healthStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vaccinationController,
                decoration: const InputDecoration(
                  labelText: 'Vaccine / Treatment Name',
                  prefixIcon: Icon(Icons.vaccines_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _medicineController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Used',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cost (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vetController,
                decoration: const InputDecoration(
                  labelText: 'Veterinarian Name',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes / Description',
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
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Health Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
