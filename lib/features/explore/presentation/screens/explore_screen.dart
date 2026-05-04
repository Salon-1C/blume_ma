import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/blume_loading.dart';
import '../../../../shared/widgets/blume_error.dart';
import '../../../../shared/widgets/blume_empty.dart';
import '../providers/explore_notifier.dart';
import '../widgets/channel_card.dart';
import '../widgets/stream_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.play_circle_fill,
                color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            const Text('blume',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.primary)),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'En vivo y canales'),
            Tab(text: 'Todas las clases'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _LiveAndChannelsTab(),
          _AllClassesTab(),
        ],
      ),
    );
  }
}

class _LiveAndChannelsTab extends ConsumerWidget {
  const _LiveAndChannelsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(liveStreamsProvider);
    final channelsAsync = ref.watch(publicChannelsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(liveStreamsProvider);
        ref.invalidate(publicChannelsProvider);
      },
      child: CustomScrollView(
        slivers: [
          // Live streams section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.live, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text('En vivo ahora',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),
          ),
          liveAsync.when(
            loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                    height: 180,
                    child: Center(child: BlumeLoading()))),
            error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(e.toString(),
                        style: const TextStyle(
                            color: AppColors.textSecondary)))),
            data: (streams) {
              if (streams.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('No hay clases en vivo ahora mismo.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: streams.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 260,
                      child: StreamCard(
                        stream: streams[i],
                        onTap: () =>
                            context.push('/clase/${streams[i].id}/live'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Channels section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: const Text('Canales públicos',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
          channelsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ShimmerCard()),
                childCount: 4,
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
                child: BlumeError(message: e.toString())),
            data: (channels) {
              if (channels.isEmpty) {
                return const SliverToBoxAdapter(
                    child: BlumeEmpty(
                        message: 'No hay canales disponibles',
                        icon: Icons.tv_off_outlined));
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: ChannelCard(
                      channel: channels[i],
                      onTap: () =>
                          context.push('/canal/${channels[i].id}'),
                    ),
                  ),
                  childCount: channels.length,
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _AllClassesTab extends ConsumerWidget {
  const _AllClassesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamsAsync = ref.watch(publicStreamsProvider(null));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(publicStreamsProvider(null)),
      child: streamsAsync.when(
        loading: () => const ShimmerList(count: 5, itemHeight: 220),
        error: (e, _) =>
            BlumeError(message: e.toString(),
                onRetry: () => ref.invalidate(publicStreamsProvider(null))),
        data: (streams) {
          if (streams.isEmpty) {
            return const BlumeEmpty(
              message: 'No hay clases disponibles',
              subtitle: 'Vuelve más tarde para ver contenido nuevo',
              icon: Icons.video_camera_back_outlined,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: streams.length,
            itemBuilder: (_, i) => StreamCard(
              stream: streams[i],
              onTap: () {
                final s = streams[i];
                if (s.isLive) {
                  context.push('/clase/${s.id}/live');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Esta clase no está en vivo. Busca su grabación en la pestaña Grabaciones.')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
