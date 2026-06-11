import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/sale_model.dart';

class SalesState {
  final bool isLoading;
  final List<SaleModel> sales;
  final String? error;

  const SalesState({this.isLoading = false, this.sales = const [], this.error});

  SalesState copyWith({bool? isLoading, List<SaleModel>? sales, String? error}) =>
      SalesState(
        isLoading: isLoading ?? this.isLoading,
        sales: sales ?? this.sales,
        error: error,
      );
}

class SalesNotifier extends StateNotifier<SalesState> {
  final ApiService _api = ApiService();
  SalesNotifier() : super(const SalesState());

  Future<void> loadSales() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get('/sales');
      final list = (response.data['data'] as List)
          .map((e) => SaleModel.fromJson(e))
          .toList();
      state = state.copyWith(isLoading: false, sales: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load sales');
    }
  }

  Future<bool> recordSale(Map<String, dynamic> data) async {
    try {
      await _api.post('/sales', data);
      await loadSales();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final salesProvider = StateNotifierProvider<SalesNotifier, SalesState>(
  (ref) => SalesNotifier(),
);
