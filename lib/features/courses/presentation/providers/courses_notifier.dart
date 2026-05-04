import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../explore/data/models/channel_model.dart';
import '../../../explore/data/models/stream_model.dart';
import '../../data/repositories/courses_repository.dart';

final myChannelsProvider =
    FutureProvider.autoDispose<List<ChannelModel>>((ref) {
  return ref.watch(coursesRepositoryProvider).getMyChannels();
});

final myChannelDetailProvider =
    FutureProvider.autoDispose.family<ChannelModel, String>((ref, id) {
  return ref.watch(coursesRepositoryProvider).getChannel(id);
});

final channelStreamsProvider =
    FutureProvider.autoDispose.family<List<StreamModel>, String>((ref, channelId) {
  return ref.watch(coursesRepositoryProvider).getChannelStreams(channelId);
});
