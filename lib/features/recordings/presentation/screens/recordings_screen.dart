import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/blume_loading.dart';
import '../../../../shared/widgets/blume_error.dart';
import '../../../../shared/widgets/blume_empty.dart';
import '../providers/recordings_notifier.dart';
import '../../data/models/recording_model.dart';

class RecordingsScreen extends ConsumerWidget {
  const RecordingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingsAsync = ref.watch(recordingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grabaciones')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(recordingsProvider),
        child: recordingsAsync.when(
          loading: () => const ShimmerList(count: 5, itemHeight: 100),
          error: (e, _) => BlumeError(
              message: e.toString(),
              onRetry: () => ref.invalidate(recordingsProvider)),
          data: (recordings) {
            final ready = recordings.where((r) => r.isReady).toList();
            if (ready.isEmpty) {
              return const BlumeEmpty(
                message: 'No hay grabaciones disponibles',
                subtitle: 'Las grabaciones aparecen aquí cuando están listas',
                icon: Icons.video_library_outlined,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ready.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _RecordingCard(
                recording: ready[i],
                onTap: () => context.push('/grabacion/${ready[i].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  const _RecordingCard({required this.recording, required this.onTap});

  final RecordingModel recording;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            _Thumbnail(recording: recording),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recording.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recording.instructorName,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          recording.formattedDuration,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.play_circle_outline,
                  color: AppColors.primary, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.recording});
  final RecordingModel recording;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 80,
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Icon(Icons.video_file_outlined,
            color: Colors.white38, size: 32),
      ),
    );
  }
}
