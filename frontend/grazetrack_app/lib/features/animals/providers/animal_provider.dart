import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/animal_model.dart';

class AnimalState {
  final bool isLoading;
  final List<AnimalModel> animals;
  final String? error;

  const AnimalState({this.isLoading = false, this.animals = const [], this.error});

  AnimalState copyWith({bool? isLoading, List<AnimalModel>? animals, String? error}) {
    return AnimalState(
      isLoading: isLoading ?? this.isLoading,
      animals: animals ?? this.animals,
      error: error,
    );
  }
}

class AnimalNotifier extends StateNotifier<AnimalState> {
  final ApiService _api = ApiService();

  AnimalNotifier() : super(const AnimalState());

  Future<void> loadAnimals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get('/animals');
      final list = (response.data['data'] as List)
          .map((e) => AnimalModel.fromJson(e))
          .toList();
      state = state.copyWith(isLoading: false, animals: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load animals');
    }
  }

  Future<bool> createAnimal(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/animals', data);
      final newAnimal = AnimalModel.fromJson(response.data['data']);
      state = state.copyWith(animals: [newAnimal, ...state.animals]);
      loadAnimals();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAnimal(String id, Map<String, dynamic> data) async {
    try {
      final response = await _api.put('/animals/$id', data);
      final updated = AnimalModel.fromJson(response.data['data']);
      state = state.copyWith(
        animals: state.animals.map((a) => a.id == id ? updated : a).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Fetch a single animal from the API and update/insert it in state.
  // Used by detail screen to always show fresh data from the database.
  Future<void> fetchAnimalById(String id) async {
    try {
      final response = await _api.get('/animals/$id');
      final animal = AnimalModel.fromJson(response.data['data']);
      final exists = state.animals.any((a) => a.id == id);
      final updated = exists
          ? state.animals.map((a) => a.id == id ? animal : a).toList()
          : [animal, ...state.animals];
      state = state.copyWith(animals: updated);
    } catch (_) {}
  }

  Future<bool> deleteAnimal(String id) async {
    try {
      await _api.delete('/animals/$id');
      await loadAnimals();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final animalProvider = StateNotifierProvider<AnimalNotifier, AnimalState>(
  (ref) => AnimalNotifier(),
);
