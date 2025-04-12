// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String title,
    String? description,
    String? prize,
    double? price,
    String? status,
    @JsonKey(name: 'winner_id') String? winnerId,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    Duration? duration,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);
}

// Custom converter functions for duration
Duration? _durationFromJson(String? value) {
  if (value == null) return null;
  final daysMatch = RegExp(r'(\d+)\s*days').firstMatch(value);
  if (daysMatch != null) {
    final days = int.tryParse(daysMatch.group(1) ?? '0') ?? 0;
    return Duration(days: days);
  }
  return null;
}

String? _durationToJson(Duration? duration) {
  if (duration == null) return null;
  return '${duration.inDays} days';
}
