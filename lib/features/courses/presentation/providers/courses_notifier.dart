import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/demo/demo_data.dart';
import '../../../explore/data/models/channel_model.dart';
import '../../../explore/data/models/stream_model.dart';
import '../../data/repositories/courses_repository.dart';

final myChannelsProvider =
    FutureProvider.autoDispose<List<ChannelModel>>((ref) {
  if (ref.watch(demoModeProvider)) {
    return Future.value(DemoData.channels.take(2).toList());
  }
  return ref.watch(coursesRepositoryProvider).getMyChannels();
});

final myChannelDetailProvider =
    FutureProvider.autoDispose.family<ChannelModel, String>((ref, id) {
  if (ref.watch(demoModeProvider)) {
    return Future.value(
      DemoData.channels.firstWhere((c) => c.id == id,
          orElse: () => DemoData.channels.first),
    );
  }
  return ref.watch(coursesRepositoryProvider).getChannel(id);
});

final channelStreamsProvider =
    FutureProvider.autoDispose.family<List<StreamModel>, String>((ref, channelId) {
  if (ref.watch(demoModeProvider)) {
    return Future.value(DemoData.streamsForChannel(channelId));
  }
  return ref.watch(coursesRepositoryProvider).getChannelStreams(channelId);
});
