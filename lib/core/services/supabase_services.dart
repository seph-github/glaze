import 'dart:developer';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../result_handler/results.dart';

part 'supabase_services.g.dart';

@riverpod
SupabaseService supabaseService(ref) {
  return SupabaseService.instance;
}

class SupabaseService {
  SupabaseService._();

  static SupabaseService instance = SupabaseService._();

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

  Future<List<Map<String, dynamic>>> selectById({
    required String table,
    required String id,
  }) async {
    final response = await supabase.from(table).select().eq('id', id);
    return response;
  }

  Future<Map<String, dynamic>> findById({
    required String table,
    required String id,
  }) async {
    final response = await supabase.from(table).select().eq('id', id);
    return response.first;
  }

  Future<List<Map<String, dynamic>>> filterByColumn({
    required String table,
    required String column,
    required String value,
  }) async {
    final response = await supabase.from(table).select().eq(column, value);
    return response;
  }

  Future<List<Map<String, dynamic>>> filterById({
    required String table,
    required String id,
  }) async {
    final response = await supabase.from(table).select().eq('id', id);
    return response;
  }

  Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    await supabase.from(table).insert(data);
  }

  Future<void> voidFunctionRpc({
    required String fn,
    Map<String, dynamic>? params,
  }) async {
    await supabase.rpc(
      fn,
      params: params,
    );
  }

  Future<List<Map<String, dynamic>>> withReturnValuesRpc(
      {required String fn, Map<String, dynamic>? params}) async {
    try {
      return await supabase.rpc(
        fn,
        params: params,
      );
    } catch (e) {
      throw Exception('SupabaseService.withReturnValuesRpc: $e');
    }
  }

  Future<void> update({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await supabase.from(table).update(data).eq('id', id);
    } catch (e) {
      log('SupabaseService.update: $e');
      Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
      throw Exception('SupabaseService.update: $e');
    }
  }

  Future<void> delete({
    required String table,
    required String id,
  }) async {
    await supabase.from(table).delete().eq('id', id);
  }

  Future<Result<String, Exception>> upload({
    required File file,
    required String userId,
    required String bucketName,
  }) async {
    try {
      final String dirName = '$userId/${file.path.split('/').last}';

      final result =
          await supabase.storage.from(bucketName).upload(dirName, file);

      final url = supabase.storage.from(bucketName).getPublicUrl(result);
      final filteredUrl = removeDuplicateWords(url);

      return Success<String, Exception>(filteredUrl); //filteredUrl;
    } on StorageException catch (e) {
      return Failure<String, Exception>(e);
    } on Exception catch (e) {
      return Failure<String, Exception>(e);
    }
  }

  String removeDuplicateWords(String url) {
    final parts = url.split('/');
    final uniqueParts = parts.toSet().toList();
    return uniqueParts.join('/');
  }
}
