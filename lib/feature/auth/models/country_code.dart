// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_code.freezed.dart';
part 'country_code.g.dart';

@freezed
class CountryCode with _$CountryCode {
  const factory CountryCode({
    required String code,
    required String name,
    @JsonKey(name: 'dial_code') required String dialCode,
  }) = _CountryCode;

  factory CountryCode.fromJson(Map<String, dynamic> json) => _$CountryCodeFromJson(json);
}
