class VideoEntity {
  final String userId;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String? caption;
  final String? category;
  final int? glazesCount;
  final String? status;
  final DateTime? createdAt;

  VideoEntity({
    required this.userId,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.caption,
    this.category,
    this.glazesCount,
    this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'caption': caption,
      'category': category,
      'glazes_count': glazesCount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class VideoEntityWithUser extends VideoEntity {
  final String username;
  final String profileImageUrl;

  VideoEntityWithUser({
    required super.userId,
    required super.title,
    required super.videoUrl,
    required super.thumbnailUrl,
    super.caption,
    super.category,
    super.glazesCount,
    super.status,
    super.createdAt,
    required this.username,
    required this.profileImageUrl,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'username': username,
      'profileImageUrl': profileImageUrl,
    });
    return map;
  }
}
