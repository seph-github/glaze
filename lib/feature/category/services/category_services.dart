import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/category.dart';

class CategoryServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _supabaseClient.from('categories').select();

      if (response.isEmpty) return [];

      final raw = response as List<dynamic>;

      return raw
          .map(
            (category) => Category.fromJson(category as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
