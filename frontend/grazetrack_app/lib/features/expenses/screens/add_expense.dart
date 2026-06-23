import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/expense_provider.dart';
import '../../animals/providers/animal_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedAnimalId;
  String _selectedType = AppConstants.expenseTypes.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(animalProvider.notifier).loadAnimals());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(expenseProvider.notifier).createExpense({
      'type': _selectedType,
      'description': _descriptionController.text.trim(),
      'amount': double.tryParse(_amountController.text) ?? 0,
      'animalId': _selectedAnimalId ?? '',
      'date': DateTime.now().toIso8601String(),
    });

    setState(() => _isLoading = false);
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      if (success) {
        AppUtils.showSnackBar(context, l10n.expenseRecorded);
        context.pop();
      } else {
        AppUtils.showSnackBar(context, l10n.expenseRecordFailed, isError: true);
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
      appBar: AppBar(title: Text(l10n.recordExpenseTitle)),
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
                  labelText: l10n.expenseTypeRequired,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: AppConstants.expenseTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionRequired,
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.amountRequired,
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? l10n.amountRequiredValidator : null,
              ),
              const SizedBox(height: 12),
              if (animalState.isLoading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedAnimalId,
                  decoration: InputDecoration(
                    labelText: l10n.linkToAnimal,
                    prefixIcon: const Icon(Icons.pets),
                  ),
                  hint: Text(l10n.selectAnimalOptional),
                  items: [
                    DropdownMenuItem(value: '', child: Text(l10n.none)),
                    ...activeAnimals.map((a) {
                      final label = a.name.isNotEmpty
                          ? '${a.name} (${a.type})'
                          : a.type;
                      return DropdownMenuItem(value: a.id, child: Text(label));
                    }),
                  ],
                  onChanged: (val) =>
                      setState(() => _selectedAnimalId = val == '' ? null : val),
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
                    : Text(l10n.saveExpense),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
