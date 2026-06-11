import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/feed_model.dart';

class FeedState {
  final bool isLoading;
  final List<FeedModel> records;
  final String? error;

  const FeedState({this.isLoading = false, this.records = const [], this.error});

  FeedState copyWith({bool? isLoading, List<FeedModel>? records, String? error}) =>
      FeedState(
        isLoading: isLoading ?? this.isLoading,
        records: records ?? this.records,
        error: error,
      );
}

class FeedNotifier extends StateNotifier<FeedState> {
  final ApiService _api = ApiService();
  FeedNotifier() : super(const FeedState());

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get('/feed');
      final list = (response.data['data'] as List)
          .map((e) => FeedModel.fromJson(e))
          .toList();
      state = state.copyWith(isLoading: false, records: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load feed records');
    }
  }

  Future<bool> createFeed(Map<String, dynamic> data) async {
    try {
      await _api.post('/feed', data);
      await loadFeed();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteFeed(String id) async {
    try {
      await _api.delete('/feed/$id');
      await loadFeed();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(),
);
