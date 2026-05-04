import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../explore/data/models/stream_model.dart';
import '../../data/repositories/streams_repository.dart';

final streamDetailByIdProvider =
    FutureProvider.autoDispose.family<StreamModel, String>((ref, id) {
  return ref.watch(streamsRepositoryProvider).getStream(id);
});

final viewerCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(streamsRepositoryProvider).getViewerCount();
});
