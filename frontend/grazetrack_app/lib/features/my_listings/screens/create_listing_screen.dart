import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../my_listings_provider.dart';
import '../../animals/models/animal_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingListing; // non-null = edit mode

  const CreateListingScreen({super.key, this.existingListing});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _picker = ImagePicker();

  // ─── Controllers ──────────────────────────────────────────────────────────
  final _breedCtrl    = TextEditingController();
  final _ageCtrl      = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');

  String _animalType = 'Cow';
  String _status     = 'available';

  // ─── Image state ──────────────────────────────────────────────────────────
  List<XFile> _newImages = [];          // newly picked images (File objects)
  List<String> _existingUrls = [];      // already-uploaded URLs (edit mode)
  bool _uploadingImages = false;

  static const int _maxImages = 5;

  // ─── Farm animals picker ───────────────────────────────────────────────────
  List<AnimalModel> _myAnimals  = [];
  bool _loadingAnimals          = false;
  AnimalModel? _selectedAnimal;

  static const _animalTypes = [
    'Cow', 'Goat', 'Sheep', 'Pig', 'Chicken', 'Horse', 'Camel', 'Other'
  ];

  bool get _isEditing => widget.existingListing != null;
  String get _title   => _isEditing ? 'Edit Listing' : 'Create Listing';

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _prefill(widget.existingListing!);
    } else {
      _fetchMyAnimals();
    }
  }

  Future<void> _fetchMyAnimals() async {
    setState(() => _loadingAnimals = true);
    try {
      final res  = await _api.get('/animals');
      final data = res.data as Map<String, dynamic>;
      final list = List<Map<String, dynamic>>.from(data['data'] ?? []);
      final animals = list
          .map((j) => AnimalModel.fromJson(j))
          .where((a) => a.status == 'active')
          .toList();
      setState(() {
        _myAnimals      = animals;
        _loadingAnimals = false;
      });
    } catch (_) {
      setState(() => _loadingAnimals = false);
    }
  }

  void _prefill(Map<String, dynamic> l) {
    _animalType = l['animalType'] ?? 'Cow';
    _breedCtrl.text    = l['breed']         ?? '';
    _ageCtrl.text      = (l['age'] ?? 0).toString();
    _priceCtrl.text    = (l['price'] ?? 0).toString();
    _descCtrl.text     = l['description']   ?? '';
    _locationCtrl.text = l['farmLocation']  ?? '';
    _phoneCtrl.text    = l['contactPhone']  ?? '';
    _emailCtrl.text    = l['contactEmail']  ?? '';
    _quantityCtrl.text = (l['quantity'] ?? 1).toString();
    _status            = l['status']        ?? 'available';
    _existingUrls      = List<String>.from(l['images'] ?? []);
  }

  void _fillFromAnimal(AnimalModel animal) {
    setState(() {
      _selectedAnimal = animal;
      _animalType     = animal.type;
      _breedCtrl.text = animal.breed;
      _ageCtrl.text   = animal.currentAge.toString();
      if (animal.notes.isNotEmpty) _descCtrl.text = animal.notes;
    });
  }

  // ─── Image helpers ────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final remaining = _maxImages - _existingUrls.length - _newImages.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $_maxImages photos allowed')),
      );
      return;
    }
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      // Respect the max-5 limit
      final toAdd = picked.take(remaining).toList();
      _newImages  = [..._newImages, ...toAdd];
    });
  }

  void _removeNewImage(int index) =>
      setState(() => _newImages.removeAt(index));

  void _removeExistingUrl(int index) =>
      setState(() => _existingUrls.removeAt(index));

  /// Uploads all newly picked images to Firebase Storage and returns their URLs.
  Future<List<String>> _uploadNewImages() async {
    final storage = FirebaseStorage.instance;
    final urls    = <String>[];
    final millis  = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < _newImages.length; i++) {
      final file = File(_newImages[i].path);
      final ref  = storage
          .ref('listings/${millis}_$i.jpg');
      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  @override
  void dispose() {
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Upload any newly picked images first
    List<String> allImages = [..._existingUrls];
    if (_newImages.isNotEmpty) {
      setState(() => _uploadingImages = true);
      try {
        final newUrls = await _uploadNewImages();
        allImages.addAll(newUrls);
      } catch (e) {
        setState(() => _uploadingImages = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: Colors.red,
          ));
        }
        return;
      }
      setState(() => _uploadingImages = false);
    }

    final data = {
      'animalType':    _animalType,
      'breed':         _breedCtrl.text.trim(),
      'age':           int.tryParse(_ageCtrl.text) ?? 0,
      'price':         double.tryParse(_priceCtrl.text) ?? 0,
      'description':   _descCtrl.text.trim(),
      'farmLocation':  _locationCtrl.text.trim(),
      'contactPhone':  _phoneCtrl.text.trim(),
      'contactEmail':  _emailCtrl.text.trim(),
      'quantity':      int.tryParse(_quantityCtrl.text) ?? 1,
      'images':        allImages,
      if (_selectedAnimal != null) 'farmAnimalId': _selectedAnimal!.id,
      if (_isEditing) 'status': _status,
    };

    bool ok;
    if (_isEditing) {
      ok = await ref
          .read(myListingsProvider.notifier)
          .updateListing(widget.existingListing!['id'], data);
    } else {
      ok = await ref.read(myListingsProvider.notifier).createListing(data);
    }

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing
            ? 'Listing updated successfully!'
            : 'Listing published! Buyers can now find it in the marketplace.'),
        backgroundColor: Colors.green,
      ));
      context.pop();
    } else {
      final err = ref.read(myListingsProvider).error ?? 'Something went wrong';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state      = ref.watch(myListingsProvider);
    final isBusy     = state.isSaving || _uploadingImages;
    final totalImages = _existingUrls.length + _newImages.length;

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ══════════════════════════════════════════════════
              // PHOTO SECTION
              // ══════════════════════════════════════════════════
              _sectionHeader('Animal Photos'),
              Text(
                'Add up to $_maxImages photos to help buyers see your animal.',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // "Add photos" tile — only shown when below the limit
                    if (totalImages < _maxImages)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.primaryGreen.withAlpha(120),
                                style: BorderStyle.solid,
                                width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: AppTheme.primaryGreen, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                'Add Photos\n($totalImages/$_maxImages)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Existing uploaded URLs (edit mode)
                    ..._existingUrls.asMap().entries.map((e) =>
                        _ImageThumb.network(
                          url: e.value,
                          onRemove: () => _removeExistingUrl(e.key),
                        )),

                    // Newly picked local images
                    ..._newImages.asMap().entries.map((e) =>
                        _ImageThumb.file(
                          file: File(e.value.path),
                          onRemove: () => _removeNewImage(e.key),
                        )),
                  ],
                ),
              ),

              if (_uploadingImages) ...[
                const SizedBox(height: 8),
                Row(children: const [
                  SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Uploading photos…',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ],

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              // ══════════════════════════════════════════════════
              // STEP 1 — Select from farm animals (create mode)
              // ══════════════════════════════════════════════════
              if (!_isEditing) ...[
                _sectionHeader('Step 1: Select Your Farm Animal'),
                const Text(
                  'Pick one of your active farm animals. The form will be pre-filled automatically.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),

                if (_loadingAnimals)
                  const Center(child: CircularProgressIndicator())
                else if (_myAnimals.isEmpty)
                  _NoAnimalsCard()
                else
                  _AnimalPickerCard(
                    animals: _myAnimals,
                    selected: _selectedAnimal,
                    onSelect: _fillFromAnimal,
                  ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                _sectionHeader('Step 2: Listing Details'),
                const Text(
                  'Review and complete the information below before publishing.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
              ],

              // ══════════════════════════════════════════════════
              // LISTING FORM
              // ══════════════════════════════════════════════════

              const Text('Animal Type *',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _animalType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                items: _animalTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _animalType = v!),
              ),
              const SizedBox(height: 16),

              _Field(
                controller: _breedCtrl,
                label: 'Breed *',
                hint: 'e.g. Friesian, Boer Goat',
                icon: Icons.category_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Breed is required' : null,
              ),

              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: _ageCtrl,
                      label: 'Age (months) *',
                      hint: '12',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      controller: _quantityCtrl,
                      label: 'Quantity *',
                      hint: '1',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              _Field(
                controller: _priceCtrl,
                label: 'Asking Price (GHS) *',
                hint: '1500.00',
                icon: Icons.attach_money,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Price is required';
                  if (double.tryParse(v) == null) return 'Invalid price';
                  return null;
                },
              ),

              _Field(
                controller: _descCtrl,
                label: 'Description',
                hint: 'Health status, vaccination history, special features…',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),

              _Field(
                controller: _locationCtrl,
                label: 'Farm Location *',
                hint: 'e.g. Kumasi, Ashanti Region',
                icon: Icons.location_on_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Location is required' : null,
              ),

              _Field(
                controller: _phoneCtrl,
                label: 'Contact Phone *',
                hint: '0241234567',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Phone is required' : null,
              ),

              _Field(
                controller: _emailCtrl,
                label: 'Contact Email (optional)',
                hint: 'farmer@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              // Status dropdown (edit mode only)
              if (_isEditing) ...[
                const Text('Status',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.toggle_on_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'available', child: Text('Available')),
                    DropdownMenuItem(value: 'sold', child: Text('Sold')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isBusy ? null : _submit,
                  icon: isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.storefront_outlined),
                  label: Text(
                    _uploadingImages
                        ? 'Uploading photos…'
                        : state.isSaving
                            ? 'Publishing…'
                            : _isEditing
                                ? 'Update Listing'
                                : 'Publish to Marketplace',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
}

// ─── Image thumbnail widget ───────────────────────────────────────────────────

class _ImageThumb extends StatelessWidget {
  final Widget image;
  final VoidCallback onRemove;

  const _ImageThumb({required this.image, required this.onRemove});

  factory _ImageThumb.file({required File file, required VoidCallback onRemove}) =>
      _ImageThumb(
        onRemove: onRemove,
        image: Image.file(file, fit: BoxFit.cover),
      );

  factory _ImageThumb.network(
          {required String url, required VoidCallback onRemove}) =>
      _ImageThumb(
        onRemove: onRemove,
        image: Image.network(url, fit: BoxFit.cover),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          clipBehavior: Clip.antiAlias,
          child: image,
        ),
        Positioned(
          top: 4,
          right: 14,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Farm Animal Picker Card ──────────────────────────────────────────────────

class _AnimalPickerCard extends StatelessWidget {
  final List<AnimalModel> animals;
  final AnimalModel? selected;
  final ValueChanged<AnimalModel> onSelect;

  const _AnimalPickerCard({
    required this.animals,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selected != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryGreen.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${selected!.type} — ${selected!.breed} (${selected!.currentAge} months)',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: animals.length,
            itemBuilder: (_, i) {
              final a          = animals[i];
              final isSelected = selected?.id == a.id;
              return GestureDetector(
                onTap: () => onSelect(a),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 130,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : Colors.grey.withAlpha(80),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(12),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: isSelected
                                ? Colors.white.withAlpha(60)
                                : AppTheme.primaryGreen.withAlpha(30),
                            child: Text(
                              a.type.isNotEmpty ? a.type[0].toUpperCase() : '?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.primaryGreen),
                            ),
                          ),
                          if (isSelected) ...[
                            const Spacer(),
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.name.isNotEmpty ? a.name : a.type,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        a.breed.isNotEmpty ? a.breed : 'Unknown breed',
                        style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white70 : Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${a.currentAge} months',
                        style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white70 : Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        const Text('← Scroll to see all animals',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

// ─── No animals card ──────────────────────────────────────────────────────────

class _NoAnimalsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(80)),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(height: 8),
          const Text(
            'No active farm animals found.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add animals to your farm first, then come back to list them for sale.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => context.push('/animals/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Farm Animal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable text field ──────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
