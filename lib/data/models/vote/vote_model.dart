import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_model.freezed.dart';
part 'vote_model.g.dart';

@freezed
class VoteModel with _$VoteModel {
  const factory VoteModel({
    required String id,
    required String userId,
    required String videoId,
    required String challengeId,
    DateTime? createdAt,
  }) = _VoteModel;

  factory VoteModel.fromJson(Map<String, dynamic> json) =>
      _$VoteModelFromJson(json);
}
