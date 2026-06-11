import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/sales_provider.dart';
import '../../animals/providers/animal_provider.dart';
import '../../../core/utils/app_utils.dart';

class AddSaleScreen extends ConsumerStatefulWidget {
  const AddSaleScreen({super.key});

  @override
  ConsumerState<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends ConsumerState<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAnimalId;
  final _sellingPriceController = TextEditingController();
  final _buyerNameController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(animalProvider.notifier).loadAnimals());
  }

  @override
  void dispose() {
    _sellingPriceController.dispose();
    _buyerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(salesProvider.notifier).recordSale({
      'animalId': _selectedAnimalId ?? '',
      'sellingPrice': double.tryParse(_sellingPriceController.text) ?? 0,
      'buyerName': _buyerNameController.text.trim(),
      'notes': _notesController.text.trim(),
    });

    setState(() => _isLoading = false);
    if (mounted) {
      if (success) {
        AppUtils.showSnackBar(
            context, 'Sale recorded! Profit calculated automatically.');
        context.pop();
      } else {
        AppUtils.showSnackBar(context, 'Failed to record sale', isError: true);
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
      appBar: AppBar(title: const Text('Record Sale')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Profit/loss is calculated automatically from the animal\'s purchase cost, feed, and health expenses.',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
              TextFormField(
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Selling Price (\$) *',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Selling price required';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _buyerNameController,
                decoration: const InputDecoration(
                  labelText: 'Buyer Name (optional)',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 12),
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
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Record Sale & Calculate Profit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
