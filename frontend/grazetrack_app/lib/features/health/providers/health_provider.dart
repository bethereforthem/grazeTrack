import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/health_model.dart';

class HealthState {
  final bool isLoading;
  final List<HealthModel> records;
  final String? error;

  const HealthState({this.isLoading = false, this.records = const [], this.error});

  HealthState copyWith({bool? isLoading, List<HealthModel>? records, String? error}) =>
      HealthState(
        isLoading: isLoading ?? this.isLoading,
        records: records ?? this.records,
        error: error,
      );
}

class HealthNotifier extends StateNotifier<HealthState> {
  final ApiService _api = ApiService();
  HealthNotifier() : super(const HealthState());

  Future<void> loadHealth() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get('/health');
      final list = (response.data['data'] as List)
          .map((e) => HealthModel.fromJson(e))
          .toList();
      state = state.copyWith(isLoading: false, records: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load health records');
    }
  }

  Future<bool> createHealth(Map<String, dynamic> data) async {
    try {
      await _api.post('/health', data);
      await loadHealth();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final healthProvider = StateNotifierProvider<HealthNotifier, HealthState>(
  (ref) => HealthNotifier(),
);
