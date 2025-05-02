import 'package:glaze/feature/shop/models/shop_product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/donut/donut.dart';

class ProductServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<ShopProduct>> fetchAvailableProducts() async {
    try {
      final response = await _supabaseClient.from('shop_products').select();

      if (response.isEmpty) return [];

      final raw = response as List<dynamic>;

      return raw.map((product) => ShopProduct.fromJson(product)).toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Donut>> fetchAvailableDonuts() async {
    try {
      final response = await _supabaseClient.from('donuts').select();

      if (response.isEmpty) return [];

      final raw = response as List<dynamic>;

      return raw.map((donut) => Donut.fromJson(donut)).toList();
    } catch (error) {
      rethrow;
    }
  }
}
