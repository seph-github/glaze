// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_content.freezed.dart';
part 'video_content.g.dart';

class DateTimeConverter implements JsonConverter<DateTime?, String?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(String? json) => json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}

@freezed
class VideoContent with _$VideoContent {
  const factory VideoContent({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'username') required String username,
    @JsonKey(name: 'video_id') required String id,
    @JsonKey(name: 'video_url') required String videoUrl,
    @JsonKey(name: 'has_glazed') @Default(false) bool hasGlazed,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    @JsonKey(name: 'title') String? title,
    String? caption,
    String? category,
    @JsonKey(name: 'glazes_count') int? glazesCount,
    String? status,
    @JsonKey(name: 'created_at') @DateTimeConverter() DateTime? createdAt,
  }) = _VideoContent;

  factory VideoContent.fromJson(Map<String, dynamic> json) => _$VideoContentFromJson(json);
}
