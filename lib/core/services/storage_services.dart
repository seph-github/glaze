import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageServices {
  final SupabaseStorageClient _storageClient = Supabase.instance.client.storage;

  Future<String> upload({
    required String id,
    required String bucketName,
    required File file,
  }) async {
    try {
      final String dirName = '$id/${file.path.split('/').last}';
      final result = await _storageClient.from(bucketName).upload(dirName, file);

      final url = _storageClient.from(bucketName).getPublicUrl(result);

      return _removeDuplicateWords(url);
    } on PathNotFoundException catch (_) {
      rethrow;
    } on StorageException catch (_) {
      rethrow;
    } on PostgrestException catch (_) {
      rethrow;
    } on FileSystemException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  String _removeDuplicateWords(String url) {
    final parts = url.split('/');
    final uniqueParts = parts.toSet().toList();
    return uniqueParts.join('/');
  }
}
