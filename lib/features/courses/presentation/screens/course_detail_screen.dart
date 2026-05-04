import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/blume_loading.dart';
import '../../../../shared/widgets/blume_error.dart';
import '../../../../shared/widgets/blume_empty.dart';
import '../providers/courses_notifier.dart';
import '../../../explore/presentation/widgets/stream_card.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelAsync = ref.watch(myChannelDetailProvider(channelId));
    final streamsAsync = ref.watch(channelStreamsProvider(channelId));

    return Scaffold(
      appBar: AppBar(title: channelAsync.maybeWhen(
        data: (c) => Text(c.name),
        orElse: () => const Text('Canal'),
      )),
      body: channelAsync.when(
        loading: () => const BlumeLoading(),
        error: (e, _) => BlumeError(
            message: e.toString(),
            onRetry: () => ref.invalidate(myChannelDetailProvider(channelId))),
        data: (channel) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.description,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(channel.instructorName,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('Clases',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ),
            ),
            streamsAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: SizedBox(height: 200)),
                  childCount: 3,
                ),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: BlumeError(message: e.toString())),
              data: (streams) {
                if (streams.isEmpty) {
                  return const SliverToBoxAdapter(
                      child: BlumeEmpty(
                          message: 'No hay clases en este canal aún',
                          icon: Icons.video_camera_back_outlined));
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: StreamCard(
                        stream: streams[i],
                        onTap: () {
                          final s = streams[i];
                          if (s.isLive) {
                            context.push('/clase/${s.id}/live');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'La grabación de esta clase está en la sección Grabaciones.')),
                            );
                          }
                        },
                      ),
                    ),
                    childCount: streams.length,
                  ),
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}
