class StreamModel {
  final String id;
  final String channelId;
  final String title;
  final String description;
  final String instructorName;
  final String status; // SCHEDULED | LIVE | ENDED | CANCELLED
  final String visibility; // PUBLIC | PRIVATE | RESTRICTED
  final String accessMode; // OPEN | WHITELIST | CODE
  final String? thumbnailUrl;
  final String? startedAt;
  final String? endedAt;
  final String? streamKey;
  final String? scheduledAt;

  const StreamModel({
    required this.id,
    required this.channelId,
    required this.title,
    required this.description,
    required this.instructorName,
    required this.status,
    required this.visibility,
    required this.accessMode,
    this.thumbnailUrl,
    this.startedAt,
    this.endedAt,
    this.streamKey,
    this.scheduledAt,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      id: json['id'] as String? ?? '',
      channelId: json['channelId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructorName: json['instructorName'] as String? ?? '',
      status: json['status'] as String? ?? 'SCHEDULED',
      visibility: json['visibility'] as String? ?? 'PUBLIC',
      accessMode: json['accessMode'] as String? ?? 'OPEN',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      startedAt: json['startedAt'] as String?,
      endedAt: json['endedAt'] as String?,
      streamKey: json['streamKey'] as String?,
      scheduledAt: json['scheduledAt'] as String?,
    );
  }

  bool get isLive => status == 'LIVE';
  bool get isEnded => status == 'ENDED';
  bool get isScheduled => status == 'SCHEDULED';
  bool get isCancelled => status == 'CANCELLED';
}
