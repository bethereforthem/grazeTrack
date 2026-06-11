import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';

class MyListingsState {
  final List<Map<String, dynamic>> listings;
  final bool isLoading;
  final String? error;
  final bool isSaving;

  const MyListingsState({
    this.listings = const [],
    this.isLoading = false,
    this.error,
    this.isSaving = false,
  });

  MyListingsState copyWith({
    List<Map<String, dynamic>>? listings,
    bool? isLoading,
    String? error,
    bool? isSaving,
    bool clearError = false,
  }) {
    return MyListingsState(
      listings: listings ?? this.listings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class MyListingsNotifier extends StateNotifier<MyListingsState> {
  final ApiService _api;

  MyListingsNotifier(this._api) : super(const MyListingsState());

  Future<void> loadMyListings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.get('/listings/mine');
      final data = res.data as Map<String, dynamic>;
      state = state.copyWith(
        listings: List<Map<String, dynamic>>.from(data['data'] ?? []),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> createListing(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _api.post('/listings', data);
      await loadMyListings();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateListing(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _api.put('/listings/$id', data);
      await loadMyListings();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _api.delete('/listings/$id');
      await loadMyListings();
      return true;
    } catch (e) {
      state = state.copyWith(
          error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}

final myListingsProvider =
    StateNotifierProvider<MyListingsNotifier, MyListingsState>((ref) {
  return MyListingsNotifier(ApiService());
});
