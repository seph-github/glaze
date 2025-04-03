import '../../config/enum/achievement_type.dart';

class AchievementEntity {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? iconUrl;
  final int? threshold;
  final String? type;
  final DateTime? createdAt;

  AchievementEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.iconUrl,
    this.threshold,
    this.type,
    this.createdAt,
  });
}

extension AchievementTypeExtension on AchievementType {
  String get value => toString().split('.').last;
}

extension AchievementTypeFromString on String {
  AchievementType toAchievementType() => AchievementType.values
      .firstWhere((element) => element.value.toLowerCase() == toLowerCase());
}

extension AchievementTypeToInt on AchievementType {
  int toInt() => int.parse(toString().split('.').last);
}

extension AchievementTypeFromInt on int {
  AchievementType toAchievementType() => AchievementType.values[this];
}

extension AchievementTypeToString on AchievementType {
  String toAchievementTypeString() => toString().split('.').last;
}

extension AchievementTypeFromName on String {
  AchievementType toAchievementType() => AchievementType.values
      .firstWhere((element) => element.name.toLowerCase() == toLowerCase());
}
