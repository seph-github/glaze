import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../config/enum/feature_type.dart';

part 'feature.freezed.dart';
part 'feature.g.dart';

@freezed
class Feature with _$Feature {
  const factory Feature({
    required String id,
    required String name,
    @JsonKey(name: 'feature_key') required String featureKey,
    @Default(FeatureType.free) FeatureType type,
  }) = _Feature;

  factory Feature.fromJson(Map<String, dynamic> json) => _$FeatureFromJson(json);
}
