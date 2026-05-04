import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/blume_loading.dart';
import '../../../../shared/widgets/blume_error.dart';
import '../../../../shared/widgets/blume_empty.dart';
import '../providers/courses_notifier.dart';
import '../../../explore/presentation/widgets/channel_card.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(myChannelsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis cursos')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myChannelsProvider),
        child: channelsAsync.when(
          loading: () => const ShimmerList(count: 5),
          error: (e, _) => BlumeError(
              message: e.toString(),
              onRetry: () => ref.invalidate(myChannelsProvider)),
          data: (channels) {
            if (channels.isEmpty) {
              return BlumeEmpty(
                message: 'No estás inscrito en ningún canal',
                subtitle: 'Explora los canales disponibles y únete',
                icon: Icons.school_outlined,
                action: () => context.go('/explorar'),
                actionLabel: 'Explorar canales',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: channels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => ChannelCard(
                channel: channels[i],
                onTap: () => context.push('/canal/${channels[i].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
