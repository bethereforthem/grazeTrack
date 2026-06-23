import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/sales_provider.dart';
import '../../animals/providers/animal_provider.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

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
      final l10n = AppLocalizations.of(context);
      if (success) {
        AppUtils.showSnackBar(context, l10n.saleRecordedSuccess);
        context.pop();
      } else {
        AppUtils.showSnackBar(context, l10n.saleRecordFailed, isError: true);
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
      appBar: AppBar(title: Text(l10n.recordSaleTitle)),
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.profitAutoCalculated,
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
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
              TextFormField(
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.sellingPriceRequired,
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return l10n.sellingPriceRequiredValidator;
                  if (double.tryParse(val) == null) return l10n.enterValidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _buyerNameController,
                decoration: InputDecoration(
                  labelText: l10n.buyerNameOptional,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 12),
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
                            color: Colors.white, strokeWidth: 2))
                    : Text(l10n.recordSaleAndCalculate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
