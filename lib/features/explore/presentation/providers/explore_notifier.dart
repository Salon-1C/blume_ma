import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/channel_model.dart';
import '../../data/models/stream_model.dart';
import '../../data/repositories/explore_repository.dart';

// Public channels
final publicChannelsProvider =
    FutureProvider.autoDispose<List<ChannelModel>>((ref) {
  return ref.watch(exploreRepositoryProvider).getPublicChannels();
});

// Live streams
final liveStreamsProvider =
    FutureProvider.autoDispose<List<StreamModel>>((ref) {
  return ref.watch(exploreRepositoryProvider).getLiveStreams();
});

// Channel detail
final channelDetailProvider =
    FutureProvider.autoDispose.family<ChannelModel, String>((ref, id) {
  return ref.watch(exploreRepositoryProvider).getPublicChannel(id);
});

// All public streams with optional status filter
final publicStreamsProvider =
    FutureProvider.autoDispose.family<List<StreamModel>, String?>((ref, status) {
  return ref.watch(exploreRepositoryProvider).getAllPublicStreams(status: status);
});

// Single stream detail
final streamDetailProvider =
    FutureProvider.autoDispose.family<StreamModel, String>((ref, id) {
  return ref.watch(exploreRepositoryProvider).getStream(id);
});
