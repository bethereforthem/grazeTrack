import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';

class NotificationState {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount =>
      notifications.where((n) => n['read'] == false).length;

  NotificationState copyWith({
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      NotificationState(
        notifications: notifications ?? this.notifications,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final ApiService _api = ApiService();

  NotificationNotifier() : super(const NotificationState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.get('/notifications');
      final list = List<Map<String, dynamic>>.from(
          (res.data as Map<String, dynamic>)['data'] ?? []);
      state = state.copyWith(isLoading: false, notifications: list);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load notifications');
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _api.put('/notifications/$id/read', {});
      final updated = state.notifications
          .map((n) => n['id'] == id ? {...n, 'read': true} : n)
          .toList();
      state = state.copyWith(notifications: updated);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _api.put('/notifications/read-all', {});
      final updated = state.notifications
          .map((n) => {...n, 'read': true})
          .toList();
      state = state.copyWith(notifications: updated);
    } catch (_) {}
  }

  // Called by NotificationService when a push arrives in foreground
  void addIncoming(Map<String, dynamic> notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
    );
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
        (ref) => NotificationNotifier());
