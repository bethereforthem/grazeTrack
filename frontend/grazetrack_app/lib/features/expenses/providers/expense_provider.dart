import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/expense_model.dart';

class ExpenseState {
  final bool isLoading;
  final List<ExpenseModel> expenses;
  final String? error;

  const ExpenseState({this.isLoading = false, this.expenses = const [], this.error});

  ExpenseState copyWith({bool? isLoading, List<ExpenseModel>? expenses, String? error}) =>
      ExpenseState(
        isLoading: isLoading ?? this.isLoading,
        expenses: expenses ?? this.expenses,
        error: error,
      );
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ApiService _api = ApiService();
  ExpenseNotifier() : super(const ExpenseState());

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get('/expenses');
      final list = (response.data['data'] as List)
          .map((e) => ExpenseModel.fromJson(e))
          .toList();
      state = state.copyWith(isLoading: false, expenses: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load expenses');
    }
  }

  Future<bool> createExpense(Map<String, dynamic> data) async {
    try {
      await _api.post('/expenses', data);
      await loadExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await _api.delete('/expenses/$id');
      await loadExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }

  double get totalExpenses =>
      state.expenses.fold(0, (sum, e) => sum + e.amount);
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>(
  (ref) => ExpenseNotifier(),
);
