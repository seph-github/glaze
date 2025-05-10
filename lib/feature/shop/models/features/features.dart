import 'package:freezed_annotation/freezed_annotation.dart';

part 'features.freezed.dart';
part 'features.g.dart';

@freezed
class Features with _$Features {
  const factory Features({
    required String id,
    required String name,
    String? description,
    required String type,
    @JsonKey(name: 'feature_key') String? featureKey,
    double? price,
    @JsonKey(name: 'is_active') @Default(false) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Features;

  factory Features.fromJson(Map<String, dynamic> json) => _$FeaturesFromJson(json);
}
