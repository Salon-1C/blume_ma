import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/demo/demo_data.dart';
import '../../data/models/channel_model.dart';
import '../../data/models/stream_model.dart';
import '../../data/repositories/explore_repository.dart';

final publicChannelsProvider =
    FutureProvider.autoDispose<List<ChannelModel>>((ref) {
  if (ref.watch(demoModeProvider)) return Future.value(DemoData.channels);
  return ref.watch(exploreRepositoryProvider).getPublicChannels();
});

final liveStreamsProvider =
    FutureProvider.autoDispose<List<StreamModel>>((ref) {
  if (ref.watch(demoModeProvider)) return Future.value(DemoData.liveStreams);
  return ref.watch(exploreRepositoryProvider).getLiveStreams();
});

final channelDetailProvider =
    FutureProvider.autoDispose.family<ChannelModel, String>((ref, id) {
  if (ref.watch(demoModeProvider)) {
    return Future.value(
      DemoData.channels.firstWhere((c) => c.id == id,
          orElse: () => DemoData.channels.first),
    );
  }
  return ref.watch(exploreRepositoryProvider).getPublicChannel(id);
});

final publicStreamsProvider =
    FutureProvider.autoDispose.family<List<StreamModel>, String?>((ref, status) {
  if (ref.watch(demoModeProvider)) {
    if (status == null) return Future.value(DemoData.allStreams);
    return Future.value(
        DemoData.allStreams.where((s) => s.status == status.toUpperCase()).toList());
  }
  return ref.watch(exploreRepositoryProvider).getAllPublicStreams(status: status);
});

final streamDetailProvider =
    FutureProvider.autoDispose.family<StreamModel, String>((ref, id) {
  if (ref.watch(demoModeProvider)) {
    return Future.value(
      DemoData.allStreams.firstWhere((s) => s.id == id,
          orElse: () => DemoData.allStreams.first),
    );
  }
  return ref.watch(exploreRepositoryProvider).getStream(id);
});
