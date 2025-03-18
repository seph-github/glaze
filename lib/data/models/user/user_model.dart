import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/data/models/video/video_model.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String username,
    required String email,
    String? profileImageUrl,
    String? bio,
    int? totalGlazes,
    int? totalUploads,
    List<VideoModel>? videos,
    String? badges,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
