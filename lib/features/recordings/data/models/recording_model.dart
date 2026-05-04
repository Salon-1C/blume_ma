class RecordingModel {
  final String id;
  final String streamKey;
  final String title;
  final String description;
  final String instructorName;
  final String? startedAt;
  final String? endedAt;
  final int durationSec;
  final String objectKey;
  final String? playbackUrl;
  final String status; // ready | failed | pending
  final String createdAt;

  const RecordingModel({
    required this.id,
    required this.streamKey,
    required this.title,
    required this.description,
    required this.instructorName,
    this.startedAt,
    this.endedAt,
    required this.durationSec,
    required this.objectKey,
    this.playbackUrl,
    required this.status,
    required this.createdAt,
  });

  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    return RecordingModel(
      id: json['id'] as String? ?? '',
      streamKey: json['streamKey'] as String? ?? '',
      title: json['title'] as String? ?? 'Sin título',
      description: json['description'] as String? ?? '',
      instructorName: json['instructorName'] as String? ?? '',
      startedAt: json['startedAt'] as String?,
      endedAt: json['endedAt'] as String?,
      durationSec: (json['durationSec'] as num?)?.toInt() ?? 0,
      objectKey: json['objectKey'] as String? ?? '',
      playbackUrl: json['playbackUrl'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  bool get isReady => status == 'ready';

  String get formattedDuration {
    final h = durationSec ~/ 3600;
    final m = (durationSec % 3600) ~/ 60;
    final s = durationSec % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}
