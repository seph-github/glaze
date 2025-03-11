import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> select({
    required String table,
    String? filterColumn,
    String? filterValue,
  }) async {
    var query = supabase.from(table).select();

    if (filterColumn != null && filterValue != null) {
      query = query.eq(filterColumn, filterValue);
    }

    final response = await query;
    return response;
  }

  Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    await supabase.from(table).insert(data);
  }

  Future<void> update({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await supabase.from(table).update(data).eq('id', id);
  }

  Future<void> delete({
    required String table,
    required String id,
  }) async {
    await supabase.from(table).delete().eq('id', id);
  }
}
