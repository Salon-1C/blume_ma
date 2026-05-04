import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/channel_model.dart';
import '../models/stream_model.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepository(ref.watch(dioProvider));
});

class ExploreRepository {
  final Dio _dio;
  ExploreRepository(this._dio);

  Future<List<ChannelModel>> getPublicChannels() async {
    final response = await _dio.get(ApiConstants.explorarCanales);
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

  Future<ChannelModel> getPublicChannel(String id) async {
    final response =
        await _dio.get('${ApiConstants.explorarCanales}/$id');
    final raw = response.data;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return ChannelModel.fromJson(raw['data'] as Map<String, dynamic>);
    }
    return ChannelModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<List<StreamModel>> getLiveStreams({int limit = 20, int offset = 0}) async {
    final response = await _dio.get(
      ApiConstants.clases,
      queryParameters: {
        'status': 'live',
        'type': 'public',
        'limit': limit,
        'offset': offset,
      },
    );
    return _parseStreamList(response.data);
  }

  Future<List<StreamModel>> getAllPublicStreams({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiConstants.clases,
      queryParameters: {
        if (status != null) 'status': status,
        'type': 'public',
        'limit': limit,
        'offset': offset,
      },
    );
    return _parseStreamList(response.data);
  }

  Future<StreamModel> getStream(String id) async {
    final response = await _dio.get('${ApiConstants.clases}/$id');
    final raw = response.data;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return StreamModel.fromJson(raw['data'] as Map<String, dynamic>);
    }
    return StreamModel.fromJson(raw as Map<String, dynamic>);
  }

  List<StreamModel> _parseStreamList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => StreamModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (raw is Map) {
      final data = raw['data'];
      List<dynamic> items;
      if (data is List) {
        items = data;
      } else if (data is Map) {
        items = data['items'] as List? ?? [];
      } else {
        items = [];
      }
      return items
          .map((e) => StreamModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
