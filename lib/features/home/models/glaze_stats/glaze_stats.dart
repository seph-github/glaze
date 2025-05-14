import 'package:freezed_annotation/freezed_annotation.dart';
part 'glaze_stats.freezed.dart';
part 'glaze_stats.g.dart';

@freezed
class GlazeStats with _$GlazeStats {
  const factory GlazeStats({
    @Default(0) int count,
    @Default(false) bool hasGlazed,
  }) = _GlazeStats;

  factory GlazeStats.fromJson(Map<String, dynamic> json) => _$GlazeStatsFromJson(json);
}
