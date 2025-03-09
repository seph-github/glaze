class GlazeEntity {
  final String id;
  final String userId;
  final String videoId;
  final DateTime? createdAt;

  GlazeEntity({
    required this.id,
    required this.userId,
    required this.videoId,
    this.createdAt,
  });
}

class VideoEntity {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String videoUrl;

  VideoEntity({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.videoUrl,
  });
}
