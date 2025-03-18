import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

@freezed
class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String userId,
    required String name,
    String? description,
    String? iconUrl,
    int? threshold,
    String? type,
    DateTime? createdAt,
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);
}
