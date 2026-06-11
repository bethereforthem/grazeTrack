import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';

class DashboardState {
  final bool isLoading;
  final Map<String, dynamic> stats;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.stats = const {},
    this.error,
  });

  DashboardState copyWith({bool? isLoading, Map<String, dynamic>? stats, String? error}) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiService _api = ApiService();

  DashboardNotifier() : super(const DashboardState());

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get('/reports/dashboard');
      state = state.copyWith(
        isLoading: false,
        stats: Map<String, dynamic>.from(response.data['data'] ?? {}),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load stats');
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);
