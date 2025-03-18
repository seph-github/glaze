import 'package:freezed_annotation/freezed_annotation.dart';

part 'glaze_model.freezed.dart';
part 'glaze_model.g.dart';

@freezed
class GlazeModel with _$GlazeModel {
  const factory GlazeModel({
    required String id,
    required String userId,
    required String videoId,
    DateTime? createdAt,
  }) = _GlazeModel;

  factory GlazeModel.fromJson(Map<String, dynamic> json) =>
      _$GlazeModelFromJson(json);
}
