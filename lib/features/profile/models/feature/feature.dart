import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature.freezed.dart';
part 'feature.g.dart';

@freezed
class Feature with _$Feature {
  const factory Feature({
    required String id,
    required String name,
    @JsonKey(name: 'feature_key') required String featureKey,
    required String type,
  }) = _Feature;

  factory Feature.fromJson(Map<String, dynamic> json) => _$FeatureFromJson(json);
}
