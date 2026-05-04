import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/blume_loading.dart';
import '../../../../shared/widgets/blume_error.dart';
import '../providers/stream_notifier.dart';
import '../../data/repositories/streams_repository.dart';

class LivePlayerScreen extends ConsumerStatefulWidget {
  const LivePlayerScreen({super.key, required this.streamId});

  final String streamId;

  @override
  ConsumerState<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends ConsumerState<LivePlayerScreen> {
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _playerLoading = true;
  String? _playerError;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _initPlayer(String streamKey) async {
    final hlsUrl = ref.read(streamsRepositoryProvider).buildHlsUrl(streamKey);
    try {
      _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(hlsUrl));
      await _videoCtrl!.initialize();
      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: false,
        isLive: true,
        placeholder: Container(color: Colors.black),
      );
      if (mounted) setState(() => _playerLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _playerLoading = false;
          _playerError =
              'No se pudo conectar al stream en vivo.\n\nAsegúrate de que MediaMTX esté transmitiendo y que el puerto 8888 (HLS) esté expuesto.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamAsync = ref.watch(streamDetailByIdProvider(widget.streamId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: streamAsync.when(
        loading: () => const BlumeLoading(),
        error: (e, _) => BlumeError(
            message: e.toString(),
            onRetry: () =>
                ref.invalidate(streamDetailByIdProvider(widget.streamId))),
        data: (stream) {
          // Init player once we have the stream key
          if (_playerLoading && _playerError == null && stream.streamKey != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _initPlayer(stream.streamKey!);
            });
          }

          if (!stream.isLive) {
            return _NotLive(title: stream.title);
          }

          return SafeArea(
            child: Column(
              children: [
                _TopBar(title: stream.title),
                // Video player area
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _playerError != null
                      ? _PlayerErrorView(message: _playerError!)
                      : _playerLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : Chewie(controller: _chewieCtrl!),
                ),
                // Stream info
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.live,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('EN VIVO',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8),
                              const _ViewerCount(),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(stream.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(stream.instructorName,
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                          if (stream.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(stream.description),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _ViewerCount extends ConsumerWidget {
  const _ViewerCount();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(viewerCountProvider).maybeWhen(
          data: (count) => Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('$count viendo',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        );
  }
}

class _PlayerErrorView extends StatelessWidget {
  const _PlayerErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _NotLive extends StatelessWidget {
  const _NotLive({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Esta clase no está en vivo ahora mismo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(160, 44)),
            ),
          ],
        ),
      ),
    );
  }
}
