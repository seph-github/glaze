import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/config/enum/challenge_entry_status.dart';

import '../../../home/models/video_content/video_content.dart';

part 'challenge_entry.freezed.dart';
part 'challenge_entry.g.dart';

@freezed
class ChallengeEntry with _$ChallengeEntry {
  const factory ChallengeEntry({
    @JsonKey(name: 'entry_id') required String entryId,
    @Default(ChallengeEntryStatus.pending) status,
    @JsonKey(name: 'glaze_count') @Default(0) int glazeCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'is_winner') @Default(false) bool isWinner,
    String? notes,
    required VideoContent video,
    required ProfileEntry profile,
  }) = _ChallengeEntry;

  factory ChallengeEntry.fromJson(Map<String, dynamic> json) => _$ChallengeEntryFromJson(json);
}

@freezed
class ProfileEntry with _$ProfileEntry {
  const factory ProfileEntry({
    required String id,
    String? email,
    required String username,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    @JsonKey(name: 'full_name') String? fullName,
  }) = _ProfileEntry;

  factory ProfileEntry.fromJson(Map<String, dynamic> json) => _$ProfileEntryFromJson(json);
}
