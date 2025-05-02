import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/shop/models/shop_product.dart';
import 'package:glaze/feature/shop/services/product_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/donut/donut.dart';

part 'products_provider.freezed.dart';
part 'products_provider.g.dart';

@freezed
abstract class ProductState with _$ProductState {
  const factory ProductState({
    @Default([]) List<ShopProduct> shopProduct,
    @Default([]) List<Donut> donuts,
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
      final donutResponse = await _productServices.fetchAvailableDonuts();

      if (response.isEmpty) {
        state = state.copyWith(isLoading: false, shopProduct: [], donuts: []);
        return;
      }

      state = state.copyWith(isLoading: false, shopProduct: response, donuts: donutResponse);
    } catch (error) {
      setError(error);
    }
  }
}
