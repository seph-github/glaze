// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/config/enum/challenge_participant_status.dart';

part 'enrolled_challenge.freezed.dart';
part 'enrolled_challenge.g.dart';

@freezed
class EnrolledChallenge with _$EnrolledChallenge {
  const factory EnrolledChallenge({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'challenge_id') required String challengeId,
    @JsonKey(name: 'joined_at') String? joinedAt,
    @Default(ChallengeParticipantStatus.joined)
    ChallengeParticipantStatus status,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    dynamic duration,
    @JsonKey(name: 'start_at') DateTime? startAt,
    @JsonKey(name: 'end_at') DateTime? endAt,
  }) = _EnrolledChallenge;

  factory EnrolledChallenge.fromJson(Map<String, dynamic> json) =>
      _$EnrolledChallengeFromJson(json);
}
