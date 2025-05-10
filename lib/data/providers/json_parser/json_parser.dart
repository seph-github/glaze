import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../feature/auth/models/country_code.dart';
import '../../../gen/assets.gen.dart';

part 'json_parser.g.dart';

@riverpod
Future<List<CountryCode>> countryCodes(Ref ref) async => await JsonParser.parseCountryCodes();

class JsonParser {
  static Future<List<CountryCode>> parseCountryCodes() async {
    final String response = await rootBundle.loadString(Assets.others.countryCode);
    final List<dynamic> data = json.decode(response);
    return data.map((json) => CountryCode.fromJson(json)).toList();
  }
}
