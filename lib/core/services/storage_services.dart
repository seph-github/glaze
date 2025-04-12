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
      final result =
          await _storageClient.from(bucketName).upload(dirName, file);

      final url = _storageClient.from(bucketName).getPublicUrl(result);

      print('object url: $url');
      return _removeDuplicateWords(url);
    } catch (e) {
      print('StorageServices.upload: $e');
      rethrow;
    }
  }

  String _removeDuplicateWords(String url) {
    final parts = url.split('/');
    final uniqueParts = parts.toSet().toList();
    return uniqueParts.join('/');
  }
}
