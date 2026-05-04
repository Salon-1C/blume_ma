import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../explore/data/models/stream_model.dart';

final streamsRepositoryProvider = Provider<StreamsRepository>((ref) {
  return StreamsRepository(ref.watch(dioProvider));
});

class StreamsRepository {
  final Dio _dio;
  StreamsRepository(this._dio);

  Future<StreamModel> getStream(String id) async {
    final response = await _dio.get('${ApiConstants.clases}/$id');
    final raw = response.data;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return StreamModel.fromJson(raw['data'] as Map<String, dynamic>);
    }
    return StreamModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<String> getViewerSessionUrl(String streamPath) async {
    final response = await _dio.get(
      ApiConstants.viewerSession,
      queryParameters: {'path': streamPath},
    );
    final raw = response.data;
    if (raw is Map) return raw['url'] as String? ?? '';
    return '';
  }

  Future<void> registerViewer(String streamId) async {
    try {
      await _dio.post(ApiConstants.viewerConnect, data: {'streamId': streamId});
    } catch (_) {}
  }

  Future<void> unregisterViewer(String streamId) async {
    try {
      await _dio.post(ApiConstants.viewerDisconnect, data: {'streamId': streamId});
    } catch (_) {}
  }

  Future<int> getViewerCount() async {
    try {
      final response = await _dio.get(ApiConstants.streamStats);
      final raw = response.data;
      if (raw is Map) return (raw['viewers'] as num?)?.toInt() ?? 0;
    } catch (_) {}
    return 0;
  }

  // Builds the HLS URL for live stream playback via MediaMTX
  // Requires port 8888 to be exposed from MediaMTX container
  String buildHlsUrl(String streamKey) =>
      '${ApiConstants.hlsBaseUrl}/live/$streamKey/index.m3u8';
}
