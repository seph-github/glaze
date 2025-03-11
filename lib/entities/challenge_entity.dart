class ChallengeEntity {
  final String id;
  final String title;
  final String description;
  final String prize;
  final String status;
  final String? winnerId;
  final DateTime? createdAt;

  ChallengeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.prize,
    required this.status,
    this.winnerId,
    this.createdAt,
  });
}

enum ChallengeStatus {
  created,
  started,
  finished,
  canceled,
}

extension ChallengeStatusExtension on ChallengeStatus {
  String get name => toString().split('.').last;
}

extension ChallengeStatusFromString on String {
  ChallengeStatus toChallengeStatus() => ChallengeStatus.values.byName(this);
}

extension ChallengeStatusToString on ChallengeStatus {
  String toChallengeStatusString() => toString().split('.').last;
}

extension ChallengeStatusFromInt on int {
  ChallengeStatus toChallengeStatus() => ChallengeStatus.values[this];
}

extension ChallengeStatusToInt on ChallengeStatus {
  int toChallengeStatusInt() => index;
}

extension ChallengeStatusFromName on String {
  ChallengeStatus toChallengeStatus() => ChallengeStatus.values.byName(this);
}
