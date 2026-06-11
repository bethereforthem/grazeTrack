import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/expense_provider.dart';
import '../../animals/providers/animal_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';

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
      if (success) {
        AppUtils.showSnackBar(context, 'Expense recorded!');
        context.pop();
      } else {
        AppUtils.showSnackBar(context, 'Failed to record expense', isError: true);
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
      appBar: AppBar(title: const Text('Record Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Expense Type *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.expenseTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$) *',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Amount required' : null,
              ),
              const SizedBox(height: 12),
              if (animalState.isLoading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedAnimalId,
                  decoration: const InputDecoration(
                    labelText: 'Link to Animal (optional)',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  hint: const Text('Select an animal (optional)'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('None')),
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
                    : const Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
