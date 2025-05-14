// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/config/enum/challenge_type.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String title,
    String? description,
    String? prize,
    String? status,
    ChallengeType? type,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'winner_id') String? winnerId,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @Default([]) List<String>? tags,
    @Default([]) List<String>? rules,
    @JsonKey(name: 'challenge_video_id') @Default(null) String? challengeVideoId,
    @Default(null) String? category,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);
}
