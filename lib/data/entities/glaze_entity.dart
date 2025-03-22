class GlazeEntity {
  final String userId;
  final String videoId;
  final DateTime? createdAt;

  GlazeEntity({
    required this.userId,
    required this.videoId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'video_id': videoId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
