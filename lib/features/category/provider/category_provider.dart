import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/features/category/services/category_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/category.dart';

part 'category_provider.freezed.dart';
part 'category_provider.g.dart';

@freezed
abstract class CategoryState with _$CategoryState {
  const factory CategoryState({
    @Default([]) List<Category> categories,
    @Default(false) bool isLoading,
    @Default(null) dynamic error,
  }) = _CategoryState;
  const CategoryState._();
}

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  CategoryState build() {
    return const CategoryState();
  }

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true);
    try {
      final List<Category> categories = await CategoryServices().fetchCategories();

      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}
