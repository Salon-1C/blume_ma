import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/blume_loading.dart';
import '../../../../shared/widgets/blume_error.dart';
import '../../../../shared/widgets/blume_empty.dart';
import '../providers/explore_notifier.dart';
import '../widgets/stream_card.dart';
import '../../../courses/presentation/providers/courses_notifier.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../courses/data/repositories/courses_repository.dart';

class ChannelDetailScreen extends ConsumerWidget {
  const ChannelDetailScreen({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelAsync = ref.watch(channelDetailProvider(channelId));
    final streamsAsync = ref.watch(channelStreamsProvider(channelId));
    final user = ref.watch(authNotifierProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Canal')),
      body: channelAsync.when(
        loading: () => const BlumeLoading(),
        error: (e, _) => BlumeError(
            message: e.toString(),
            onRetry: () => ref.invalidate(channelDetailProvider(channelId))),
        data: (channel) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(channel.initials,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(channel.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(channel.instructorName,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(channel.description),
                    const SizedBox(height: 20),
                    if (user != null)
                      FilledButton.icon(
                        onPressed: () async {
                          try {
                            await ref
                                .read(coursesRepositoryProvider)
                                .enrollInChannel(channelId);
                            ref.invalidate(myChannelsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('¡Inscrito al canal!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Inscribirse'),
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 46)),
                      ),
                    const SizedBox(height: 8),
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
                      child: ShimmerCard(height: 200)),
                  childCount: 3,
                ),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: BlumeError(message: e.toString())),
              data: (streams) {
                if (streams.isEmpty) {
                  return const SliverToBoxAdapter(
                      child: BlumeEmpty(
                          message: 'No hay clases en este canal',
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
                                      'Busca la grabación de esta clase en la sección Grabaciones.')),
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
