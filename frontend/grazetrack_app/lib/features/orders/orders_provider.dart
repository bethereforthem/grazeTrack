import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';

class OrdersState {
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> adminOrders;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const OrdersState({
    this.orders = const [],
    this.adminOrders = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  OrdersState copyWith({
    List<Map<String, dynamic>>? orders,
    List<Map<String, dynamic>>? adminOrders,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      adminOrders: adminOrders ?? this.adminOrders,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final ApiService _api;

  OrdersNotifier(this._api) : super(const OrdersState());

  /// Load buyer's own orders
  Future<void> loadMyOrders({String perspective = 'buyer'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.get('/orders',
          params: {'perspective': perspective});
      final data = res.data as Map<String, dynamic>;
      state = state.copyWith(
        orders: List<Map<String, dynamic>>.from(data['data'] ?? []),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Load all orders — Admin/Manager
  Future<void> loadAdminOrders() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.get('/orders/admin');
      final data = res.data as Map<String, dynamic>;
      state = state.copyWith(
        adminOrders: List<Map<String, dynamic>>.from(data['data'] ?? []),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Place a new order
  Future<Map<String, dynamic>?> placeOrder(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final res = await _api.post('/orders', data);
      final order =
          (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      await loadMyOrders();
      state = state.copyWith(isSaving: false);
      return order;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  /// Update order status (Admin/Seller)
  Future<bool> updateStatus(String orderId, String status) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _api.put('/orders/$orderId/status', {'status': status});
      await loadAdminOrders();
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
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ApiService());
});
