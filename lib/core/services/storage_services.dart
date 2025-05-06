import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/remove_duplicate_words.dart';

class StorageServices {
  final SupabaseStorageClient _storageClient = Supabase.instance.client.storage;

  Future<String> upload({
    required String id,
    required String bucketName,
    required File file,
    required String fileName,
  }) async {
    try {
      final String dirName = '$id/${DateTime.now()}-${file.path.split('/').last}';

      final result = await _storageClient.from(bucketName).upload(
            dirName,
            file,
          );
      final url = _storageClient.from(bucketName).getPublicUrl(result);

      return removeDuplicateWords(url);
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
}
