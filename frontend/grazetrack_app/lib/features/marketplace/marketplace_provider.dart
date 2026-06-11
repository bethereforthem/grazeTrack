import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class MarketplaceState {
  final List<Map<String, dynamic>> listings;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String filterType;
  final String filterLocation;
  final double? minPrice;
  final double? maxPrice;

  const MarketplaceState({
    this.listings = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterType = '',
    this.filterLocation = '',
    this.minPrice,
    this.maxPrice,
  });

  MarketplaceState copyWith({
    List<Map<String, dynamic>>? listings,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? filterType,
    String? filterLocation,
    double? minPrice,
    double? maxPrice,
    bool clearError = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return MarketplaceState(
      listings: listings ?? this.listings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      filterLocation: filterLocation ?? this.filterLocation,
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final ApiService _api;

  MarketplaceNotifier(this._api) : super(const MarketplaceState());

  Future<void> loadListings({
    String? type,
    String? location,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final params = <String, dynamic>{};
      final t = type ?? state.filterType;
      final l = location ?? state.filterLocation;
      final s = search ?? state.searchQuery;
      final mn = minPrice ?? state.minPrice;
      final mx = maxPrice ?? state.maxPrice;
      if (t.isNotEmpty) params['type'] = t;
      if (l.isNotEmpty) params['location'] = l;
      if (s.isNotEmpty) params['search'] = s;
      if (mn != null) params['minPrice'] = mn.toString();
      if (mx != null) params['maxPrice'] = mx.toString();

      final res = await _api.get('/listings', params: params);
      final data = res.data as Map<String, dynamic>;
      final listings = List<Map<String, dynamic>>.from(data['data'] ?? []);
      state = state.copyWith(
        listings: listings,
        isLoading: false,
        filterType: t,
        filterLocation: l,
        searchQuery: s,
        minPrice: mn,
        maxPrice: mx,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Map<String, dynamic>?> getListingDetail(String id) async {
    try {
      final res = await _api.get('/listings/$id');
      return (res.data as Map<String, dynamic>)['data'];
    } catch (_) {
      return null;
    }
  }

  void clearFilters() {
    state = state.copyWith(
      filterType: '',
      filterLocation: '',
      searchQuery: '',
      clearMinPrice: true,
      clearMaxPrice: true,
    );
    loadListings();
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final marketplaceProvider =
    StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
  return MarketplaceNotifier(ApiService());
});
