import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/feature/challenges/widgets/circle_stack.dart';
import 'package:intl/intl.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../config/enum/product_type.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_timer.dart';
import '../models/shop_product/shop_product.dart';

class ShopProductsCard extends StatelessWidget {
  const ShopProductsCard({
    super.key,
    required this.product,
  });

  final ShopProduct product;

  String get priceInDollars {
    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatCurrency.format(product.priceCents / 100);
  }

  Color get backgroundColor {
    if (product.color == null) {
      return ColorPallete.lilac;
    }

    final String? hex = product.color?.replaceAll('#', '');
    final hexValue = '0xFF$hex';
    return Color(int.parse(hexValue));
  }

  String get buttonText {
    switch (product.type) {
      case ProductType.featured:
        return 'Buy Premium';
      case ProductType.subscription:
        return 'Subscribe Now';
      case ProductType.donutBox:
        return 'Buy Box';
      case ProductType.bundle:
        return 'Buy All Box';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: backgroundColor.withValues(alpha: 0.2),
            border: Border.all(
              color: backgroundColor,
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      product.type.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (product.endAt != null)
                      AppTimer(
                        endDate: product.endAt!,
                        startDate: product.startAt,
                      ),
                  ],
                ),
                const Gap(5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (product.donuts != null && product.donuts!.isNotEmpty)
                      CircleStackPage(
                        children: product.donuts!.map(
                          (donut) {
                            return CachedNetworkImage(
                              imageUrl: donut.imageUrl,
                              fit: BoxFit.cover,
                              width: 32.0,
                              height: 32.0,
                            );
                          },
                        ).toList(),
                      )
                    else
                      SvgPicture.asset(
                        Assets.images.svg.glazeDonutsIcon.path,
                        fit: BoxFit.cover,
                      ),
                    const Gap(4),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.35,
                      child: Text(
                        product.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: backgroundColor,
                            ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$priceInDollars${product.type == ProductType.subscription ? '/month' : ''}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
                const Gap(5),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.75,
                      child: Text(
                        product.description ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: ColorPallete.hintTextColor,
                            ),
                      ),
                    ),
                  ],
                ),
                const Gap(5),
                if (product.features != null)
                  Column(
                    children: product.features!.map((feature) {
                      return _buildProductsBenefits(
                        context,
                        feature: feature.name,
                        fontColor: backgroundColor,
                      );
                    }).toList(),
                  ),
                const Gap(10),
                PrimaryButton(
                  label: buttonText,
                  foregroundColor: product.type == ProductType.featured ? ColorPallete.blackPearl : Colors.white,
                  backgroundColor: backgroundColor,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsBenefits(BuildContext context, {required String feature, Color? fontColor}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            Assets.images.svg.starIcon.path,
            height: 14.0,
            colorFilter: ColorFilter.mode(
              fontColor ?? ColorPallete.hintTextColor,
              BlendMode.srcIn,
            ),
          ),
          const Gap(8),
          Text(
            feature,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fontColor,
                ),
          ),
        ],
      ),
    );
  }
}
