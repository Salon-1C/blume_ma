import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/blume_loading.dart';
import '../../../../shared/widgets/blume_error.dart';
import '../providers/recordings_notifier.dart';
import '../../data/repositories/recordings_repository.dart';

class RecordingPlayerScreen extends ConsumerStatefulWidget {
  const RecordingPlayerScreen({super.key, required this.recordingId});

  final String recordingId;

  @override
  ConsumerState<RecordingPlayerScreen> createState() =>
      _RecordingPlayerScreenState();
}

class _RecordingPlayerScreenState
    extends ConsumerState<RecordingPlayerScreen> {
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

  Future<void> _initPlayer(String playUrl) async {
    try {
      _videoCtrl =
          VideoPlayerController.networkUrl(Uri.parse(playUrl));
      await _videoCtrl!.initialize();
      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        placeholder: Container(color: Colors.black),
      );
      if (mounted) setState(() => _playerLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _playerLoading = false;
          _playerError =
              'No se pudo cargar la grabación.\n${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingAsync =
        ref.watch(recordingDetailProvider(widget.recordingId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: recordingAsync.when(
        loading: () => const BlumeLoading(),
        error: (e, _) => BlumeError(
            message: e.toString(),
            onRetry: () => ref
                .invalidate(recordingDetailProvider(widget.recordingId))),
        data: (recording) {
          final playUrl = recording.playbackUrl ??
              ref.read(recordingsRepositoryProvider).getPlayUrl(recording.id);

          if (_playerLoading && _playerError == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _initPlayer(playUrl);
            });
          }

          return SafeArea(
            child: Column(
              children: [
                // Top bar
                Container(
                  color: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          recording.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Video
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _playerError != null
                      ? Container(
                          color: Colors.black,
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.white54, size: 48),
                                const SizedBox(height: 12),
                                Text(_playerError!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                        )
                      : _playerLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : Chewie(controller: _chewieCtrl!),
                ),
                // Recording info
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recording.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 16,
                                  color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(recording.instructorName,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                              const SizedBox(width: 16),
                              const Icon(Icons.timer_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(recording.formattedDuration,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                            ],
                          ),
                          if (recording.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(recording.description),
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
