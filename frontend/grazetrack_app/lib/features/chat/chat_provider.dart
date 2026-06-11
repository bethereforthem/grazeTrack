import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';

class ChatState {
  final List<Map<String, dynamic>> threads;
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> farmers; // all farmers available to chat
  final bool isLoading;
  final bool isSending;
  final bool isFarmersLoading;
  final String? error;

  const ChatState({
    this.threads = const [],
    this.messages = const [],
    this.farmers = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isFarmersLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Map<String, dynamic>>? threads,
    List<Map<String, dynamic>>? messages,
    List<Map<String, dynamic>>? farmers,
    bool? isLoading,
    bool? isSending,
    bool? isFarmersLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      threads: threads ?? this.threads,
      messages: messages ?? this.messages,
      farmers: farmers ?? this.farmers,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isFarmersLoading: isFarmersLoading ?? this.isFarmersLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _api;

  ChatNotifier(this._api) : super(const ChatState());

  // Load all conversation threads for the current user
  Future<void> loadThreads() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.get('/chat/threads');
      final data = res.data as Map<String, dynamic>;
      state = state.copyWith(
        threads: List<Map<String, dynamic>>.from(data['data'] ?? []),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // Load all active farmers so the user can start a new conversation
  Future<void> loadFarmers() async {
    state = state.copyWith(isFarmersLoading: true, clearError: true);
    try {
      final res = await _api.get('/users/farmers');
      final data = res.data as Map<String, dynamic>;
      state = state.copyWith(
        farmers: List<Map<String, dynamic>>.from(data['data'] ?? []),
        isFarmersLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isFarmersLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // Get or create a thread.
  // Pass listingId for marketplace chats, omit it for direct farmer-to-farmer chats.
  Future<String?> getOrCreateThread(String sellerId,
      {String? listingId}) async {
    try {
      final body = <String, dynamic>{'sellerId': sellerId};
      if (listingId != null) body['listingId'] = listingId;

      final res = await _api.post('/chat/thread', body);
      final data =
          (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return data['id'] as String?;
    } catch (e) {
      state = state.copyWith(
          error: e.toString().replaceFirst('Exception: ', ''));
      return null;
    }
  }

  Future<void> loadMessages(String threadId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.get('/chat/thread/$threadId/messages');
      final data = res.data as Map<String, dynamic>;
      state = state.copyWith(
        messages: List<Map<String, dynamic>>.from(data['data'] ?? []),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> sendMessage(String threadId, String content) async {
    state = state.copyWith(isSending: true);
    try {
      final res = await _api.post(
          '/chat/thread/$threadId/message', {'content': content});
      final msg =
          (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      state = state.copyWith(
        messages: [...state.messages, msg],
        isSending: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // Edit a message the current user sent.
  // Updates the local message list immediately (optimistic update).
  Future<bool> editMessage(String messageId, String newContent) async {
    try {
      await _api.put('/chat/message/$messageId', {'content': newContent});
      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m['id'] == messageId) {
            return {
              ...m,
              'content': newContent,
              'editedAt': DateTime.now().toIso8601String(),
            };
          }
          return m;
        }).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Delete a message the current user sent.
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _api.delete('/chat/message/$messageId');
      state = state.copyWith(
        messages: state.messages
            .where((m) => m['id'] != messageId)
            .toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ApiService());
});
