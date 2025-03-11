class VideoEntity {
  final String id;
  final String userId;
  final String videoUrl;
  final String thumbnailUrl;
  final String? caption;
  final String? category;
  final int? glazesCount;
  final String? status;
  final DateTime? createdAt;

  VideoEntity({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.caption,
    this.category,
    this.glazesCount,
    this.status,
    this.createdAt,
  });
}

class VideoEntityWithUser extends VideoEntity {
  final String username;
  final String profileImageUrl;

  VideoEntityWithUser({
    required super.id,
    required super.userId,
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
}
