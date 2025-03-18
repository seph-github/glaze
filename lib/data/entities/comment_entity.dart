class CommentEntity {
  final String id;
  final String userId;
  final String videoId;
  final String content;
  final DateTime? createdAt;

  CommentEntity({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.content,
    this.createdAt,
  });
}

class Comment {
  final String id;
  final String userId;
  final String videoId;
  final String content;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.content,
    this.createdAt,
  });
}
