import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

// AuthState holds the current login state
class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  const AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, Map<String, dynamic>? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

// AuthNotifier manages login/register/logout actions
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  // Called on app start — loads the user from device storage if they were
  // previously logged in, so we don't lose their session on restart.
  Future<void> _restoreSession() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) return;
    final user = await _authService.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _authService.login(email: email, password: password);
      state = state.copyWith(isLoading: false, user: data['user']);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _authService.register(
          name: name, email: email, password: password, phone: phone);
      state = state.copyWith(isLoading: false, user: data['user']);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  String _parseError(dynamic e) {
    // Extract user-friendly error message from Dio exceptions
    try {
      return e.response?.data['message'] ?? 'An error occurred';
    } catch (_) {
      return 'Connection failed. Check your internet.';
    }
  }
}

// The provider — screens use this to access auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
