import 'package:freezed_annotation/freezed_annotation.dart';

part 'donut.freezed.dart';
part 'donut.g.dart';

@freezed
class Donut with _$Donut {
  const factory Donut({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _Donut;

  factory Donut.fromJson(Map<String, dynamic> json) => _$DonutFromJson(json);
}
