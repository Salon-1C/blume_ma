class ChannelModel {
  final String id;
  final String name;
  final String description;
  final String instructorName;
  final String? instructorId;
  final String? thumbnailUrl;

  const ChannelModel({
    required this.id,
    required this.name,
    required this.description,
    required this.instructorName,
    this.instructorId,
    this.thumbnailUrl,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructorName: json['instructorName'] as String? ?? '',
      instructorId: json['instructorId'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'B';
  }
}
