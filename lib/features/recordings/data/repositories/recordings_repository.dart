import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/recording_model.dart';

final recordingsRepositoryProvider = Provider<RecordingsRepository>((ref) {
  return RecordingsRepository(ref.watch(dioProvider));
});

class RecordingsRepository {
  final Dio _dio;
  RecordingsRepository(this._dio);

  Future<List<RecordingModel>> getRecordings({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiConstants.recordings,
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final raw = response.data;
    List<dynamic> items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map) {
      final data = raw['data'];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        items = data['items'] as List? ?? [];
      } else {
        items = [];
      }
    } else {
      items = [];
    }
    return items
        .map((e) => RecordingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RecordingModel> getRecording(String id) async {
    final response = await _dio.get('${ApiConstants.recordings}/$id');
    final raw = response.data;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return RecordingModel.fromJson(raw['data'] as Map<String, dynamic>);
    }
    return RecordingModel.fromJson(raw as Map<String, dynamic>);
  }

  // Returns the streaming URL for the recording player
  String getPlayUrl(String id) =>
      '${ApiConstants.baseUrl}${ApiConstants.recordings}/$id/play';
}
