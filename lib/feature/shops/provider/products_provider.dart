import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/shops/models/shop_product.dart';
import 'package:glaze/feature/shops/services/product_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products_provider.freezed.dart';
part 'products_provider.g.dart';

@freezed
abstract class ProductState with _$ProductState {
  const factory ProductState({
    @Default([]) List<ShopProduct> shopProduct,
    @Default(false) bool isLoading,
    @Default(null) dynamic error,
  }) = _ProductState;

  const ProductState._();
}

@riverpod
class ProductsNotifier extends _$ProductsNotifier {
  @override
  ProductState build() {
    return const ProductState();
  }

  final ProductServices _productServices = ProductServices();

  void setError(dynamic error) {
    state = state.copyWith(error: null);
    state = state.copyWith(isLoading: false, error: error as Exception);
  }

  Future<void> fetchAvailableProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _productServices.fetchAvailableProducts();

      if (response.isEmpty) {
        state = state.copyWith(isLoading: false, shopProduct: []);
        return;
      }

      state = state.copyWith(isLoading: false, shopProduct: response);
    } catch (error) {
      setError(error);
    }
  }
}
