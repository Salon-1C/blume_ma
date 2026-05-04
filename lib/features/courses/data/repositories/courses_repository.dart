import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../explore/data/models/channel_model.dart';
import '../../../explore/data/models/stream_model.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepository(ref.watch(dioProvider));
});

class CoursesRepository {
  final Dio _dio;
  CoursesRepository(this._dio);

  Future<List<ChannelModel>> getMyChannels() async {
    final response = await _dio.get(ApiConstants.misCanales);
    final raw = response.data;
    List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw.containsKey('data')) {
      final data = raw['data'];
      list = data is List ? data : (data['items'] as List? ?? []);
    } else {
      list = [];
    }
    return list
        .map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChannelModel> getChannel(String id) async {
    final response = await _dio.get('${ApiConstants.misCanales}/$id');
    final raw = response.data;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return ChannelModel.fromJson(raw['data'] as Map<String, dynamic>);
    }
    return ChannelModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<void> enrollInChannel(String channelId) async {
    await _dio.post('${ApiConstants.misCanales}/$channelId/inscribirse');
  }

  Future<List<StreamModel>> getChannelStreams(String channelId) async {
    final response = await _dio.get(
      ApiConstants.clases,
      queryParameters: {'channelId': channelId},
    );
    final raw = response.data;
    List<dynamic> items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map) {
      final data = raw['data'];
      items = data is List ? data : (data['items'] as List? ?? []);
    } else {
      items = [];
    }
    return items
        .map((e) => StreamModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
