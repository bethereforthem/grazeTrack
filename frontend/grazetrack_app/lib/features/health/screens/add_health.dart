import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_provider.dart';
import '../../animals/providers/animal_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

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
      final l10n = AppLocalizations.of(context);
      if (success) {
        AppUtils.showSnackBar(context, l10n.healthRecordAdded);
        context.pop();
      } else {
        AppUtils.showSnackBar(context, l10n.healthRecordFailed, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalState = ref.watch(animalProvider);
    final l10n = AppLocalizations.of(context);
    final activeAnimals = animalState.animals
        .where((a) => a.status == 'active')
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addHealthRecordTitle)),
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
                  decoration: InputDecoration(
                    labelText: l10n.selectAnimalRequired,
                    prefixIcon: const Icon(Icons.pets),
                  ),
                  hint: Text(l10n.chooseAnimal),
                  items: activeAnimals.map((a) {
                    final label = a.name.isNotEmpty
                        ? '${a.name} (${a.type})'
                        : a.type;
                    return DropdownMenuItem(value: a.id, child: Text(label));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAnimalId = val),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? l10n.pleaseSelectAnimal : null,
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.recordTypeRequired,
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                ),
                items: AppConstants.healthTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: l10n.healthStatusRequired,
                  prefixIcon: const Icon(Icons.health_and_safety_outlined),
                ),
                items: AppConstants.healthStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vaccinationController,
                decoration: InputDecoration(
                  labelText: l10n.vaccineTreatmentName,
                  prefixIcon: const Icon(Icons.vaccines_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _medicineController,
                decoration: InputDecoration(
                  labelText: l10n.medicineUsed,
                  prefixIcon: const Icon(Icons.medication_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.costField,
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vetController,
                decoration: InputDecoration(
                  labelText: l10n.veterinarianName,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.notesDescription,
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
                    : Text(l10n.saveHealthRecord),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
