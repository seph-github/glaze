import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String userId,
    required String username,
    String? email,
    String? profilePic,
    String? country,
    String? language,
    @TimestampConverter() required DateTime createdAt,
    @Default([]) List<String> preferredCategories,
    @Default(true) bool notificationsEnabled,
    @Default([]) List<String> videosWatched,
    @Default(0) int timeSpentWatching,
    @Default(0) int videosUploaded,
    @Default([]) List<String> glazings,
    @Default(0) int shares,
    @Default(0) int comments,
    @Default([]) List<String> challengesEntered,
    String? subscription, // "free" or "premium"
    @Default([]) List<String> purchases,
    @Default(0) int adsWatched,
    String? device,
    String? osVersion,
    String? appVersion,
    @TimestampConverter() required DateTime lastActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// Firestore Timestamp Converter
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
