import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/config/enum/product_type.dart';

part 'shop_product.freezed.dart';
part 'shop_product.g.dart';

@freezed
class ShopProduct with _$ShopProduct {
  const factory ShopProduct({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'price_cents') required int priceCents,
    required ProductType type,
    int? quantity,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_discounted') @Default(false) bool isDiscounted,
    @JsonKey(name: 'discount_price_cents') int? discountPriceCents,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'donut_ids') List<String>? donutIds,
    @JsonKey(name: 'start_at') DateTime? startAt,
    @JsonKey(name: 'end_at') DateTime? endAt,
    List<String>? features,
  }) = _ShopProduct;

  factory ShopProduct.fromJson(Map<String, dynamic> json) => _$ShopProductFromJson(json);
}
