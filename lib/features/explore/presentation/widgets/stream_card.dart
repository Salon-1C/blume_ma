import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/stream_model.dart';

class StreamCard extends StatelessWidget {
  const StreamCard({
    super.key,
    required this.stream,
    required this.onTap,
  });

  final StreamModel stream;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumbnail(stream: stream),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stream.instructorName,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.stream});
  final StreamModel stream;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: stream.thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl: stream.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _placeholder(),
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _StatusBadge(status: stream.status),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1E293B),
        child: const Center(
          child: Icon(Icons.play_circle_outline, color: Colors.white38, size: 40),
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'LIVE':
        return _badge('EN VIVO', AppColors.live);
      case 'SCHEDULED':
        return _badge('PRÓXIMO', AppColors.warning);
      case 'ENDED':
        return _badge('GRABADO', AppColors.textSecondary);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
