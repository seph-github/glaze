class VoteEntity {
  final String id;
  final String userId;
  final String videoId;
  final String challengeId;
  final DateTime? createdAt;

  VoteEntity({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.challengeId,
    this.createdAt,
  });
}

class Vote {
  final String id;
  final String userId;
  final String videoId;
  final String challengeId;
  final DateTime? createdAt;

  Vote({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.challengeId,
    this.createdAt,
  });
}
