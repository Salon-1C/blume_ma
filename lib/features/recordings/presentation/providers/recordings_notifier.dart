import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/demo/demo_data.dart';
import '../../data/models/recording_model.dart';
import '../../data/repositories/recordings_repository.dart';

final recordingsProvider =
    FutureProvider.autoDispose<List<RecordingModel>>((ref) {
  if (ref.watch(demoModeProvider)) return Future.value(DemoData.recordings);
  return ref.watch(recordingsRepositoryProvider).getRecordings();
});

final recordingDetailProvider =
    FutureProvider.autoDispose.family<RecordingModel, String>((ref, id) {
  if (ref.watch(demoModeProvider)) {
    return Future.value(
      DemoData.recordings.firstWhere((r) => r.id == id,
          orElse: () => DemoData.recordings.first),
    );
  }
  return ref.watch(recordingsRepositoryProvider).getRecording(id);
});
