class UserModel {
  final String userId;
  final String email;
  final String fullName;
  final String? username;
  final String role;
  final String provider;

  const UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.username,
    required this.role,
    required this.provider,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      username: json['username'] as String?,
      role: json['role'] as String? ?? 'STUDENT',
      provider: json['provider'] as String? ?? 'LOCAL',
    );
  }

  bool get isStudent => role == 'STUDENT';
  bool get isProfessor => role == 'PROFESSOR';
  bool get needsOnboarding => username == null || username!.isEmpty;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }
}
