import 'package:glaze/core/services/storage_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_services_provider.g.dart';

@riverpod
StorageServices storageServices(ref) {
  return StorageServices();
}
