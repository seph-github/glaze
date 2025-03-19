// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'glaze_model.freezed.dart';
part 'glaze_model.g.dart';

@freezed
class GlazeModel with _$GlazeModel {
  const factory GlazeModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'video_id') required String videoId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _GlazeModel;

  factory GlazeModel.fromJson(Map<String, dynamic> json) =>
      _$GlazeModelFromJson(json);
}
