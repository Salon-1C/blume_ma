import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recording_model.dart';
import '../../data/repositories/recordings_repository.dart';

final recordingsProvider =
    FutureProvider.autoDispose<List<RecordingModel>>((ref) {
  return ref.watch(recordingsRepositoryProvider).getRecordings();
});

final recordingDetailProvider =
    FutureProvider.autoDispose.family<RecordingModel, String>((ref, id) {
  return ref.watch(recordingsRepositoryProvider).getRecording(id);
});
