import 'package:glaze/data/models/category/category_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/supabase_services.dart';

part 'category_repository.g.dart';

@riverpod
CategoryRepository categoryRepository(ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return CategoryRepository(supabaseService: supabaseService);
}

@riverpod
class CategoriesNotifier extends _$CategoriesNotifier {
  @override
  FutureOr<List<CategoryModel>> build() async => await fetchCategories();

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async =>
            await ref.read(categoryRepositoryProvider).fetchCategories(),
      );
      return Future.value(state.value);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      throw Exception('CategoriesNotifier.fetchCategories: $e');
    }
  }
}

class CategoryRepository {
  const CategoryRepository({
    required SupabaseService supabaseService,
  }) : _supabaseService = supabaseService;

  final SupabaseService _supabaseService;

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final List<Map<String, dynamic>> result =
          await _supabaseService.select(table: 'categories');

      if (result.isEmpty) {
        return [];
      }

      return result.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('CategoryRepository.fetchCategories: $e');
    }
  }
}
