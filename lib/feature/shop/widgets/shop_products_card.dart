import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/feature/challenges/widgets/circle_stack.dart';
import 'package:intl/intl.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_timer.dart';
import '../models/shop_product.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: backgroundColor.withValues(alpha: 0.3),
            border: Border.all(
              color: backgroundColor,
              width: 1,
            ),
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
                    Row(
                      children: [
                        SvgPicture.asset(
                          Assets.images.svg.timerIcon.path,
                          height: 24.0,
                        ),
                        const Gap(4),
                        AppTimer(
                          endDate: product.endAt!,
                          startDate: product.startAt,
                        ),
                      ],
                    ),
                ],
              ),
              const Gap(5),
              Row(
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
                  const Gap(8),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: backgroundColor,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    priceInDollars,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: backgroundColor),
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
              // Column(
              //   children: <Widget>[
              //     _buildProductsBenefits(context),
              //     const Gap(5),
              //     _buildProductsBenefits(context),
              //     const Gap(5),
              //     _buildProductsBenefits(context),
              //   ],
              // ),
              const Gap(10),
              PrimaryButton(
                label: 'Buy Premium',
                foregroundColor: ColorPallete.blackPearl,
                backgroundColor: backgroundColor,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row buildProductsBenefits(BuildContext context) {
    return Row(
      children: <Widget>[
        SvgPicture.asset(
          Assets.images.svg.starIcon.path,
          height: 14.0,
          colorFilter: const ColorFilter.mode(
            Colors.amber,
            BlendMode.srcIn,
          ),
        ),
        const Gap(10),
        Text(
          'Unlock special perks and bonuses.',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.amber),
        ),
      ],
    );
  }
}
