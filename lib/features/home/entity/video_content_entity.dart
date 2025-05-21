class VideoContentEntity {
  final String userId;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String? caption;
  final String? category;
  final int? glazesCount;
  final String? status;
  final DateTime? createdAt;
  final String? location;
  final String? latitude;
  final String? longitude;
  final List<String>? tags;

  VideoContentEntity({
    required this.userId,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.caption,
    this.category,
    this.glazesCount,
    this.status,
    this.createdAt,
    this.location,
    this.latitude,
    this.longitude,
    this.tags,
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
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
    }..removeWhere((key, value) => value == null);
  }
}
