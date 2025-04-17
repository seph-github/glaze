// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'glaze.freezed.dart';
part 'glaze.g.dart';

@freezed
class Glaze with _$Glaze {
  const factory Glaze({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'video_id') required String videoId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Glaze;

  factory Glaze.fromJson(Map<String, dynamic> json) => _$GlazeFromJson(json);
}
