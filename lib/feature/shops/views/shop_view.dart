import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/config/enum/product_type.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/shops/provider/products_provider.dart';
import 'package:glaze/utils/app_timer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/fonts.gen.dart';
import '../../templates/loading_layout.dart';

class ShopView extends HookConsumerWidget {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(
        () async {
          ref.read(productsNotifierProvider.notifier).fetchAvailableProducts();
        },
      );
      return;
    }, []);

    final state = ref.watch(productsNotifierProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .refresh(productsNotifierProvider.notifier)
            .fetchAvailableProducts();
      },
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      color: Colors.transparent,
      child: LoadingLayout(
        isLoading: state.isLoading,
        appBar: AppBarWithBackButton(
          showBackButton: false,
          centerTitle: false,
          title: const Text('Shop'),
          titleTextStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontFamily: FontFamily.hitAndRun,
              ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverList.builder(
                  itemCount: state.shopProduct.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ShopProductsCard(
                          type: state.shopProduct[index].type,
                          title: state.shopProduct[index].name,
                          price: state.shopProduct[index].priceCents,
                          description: state.shopProduct[index].description,
                          startDate: state.shopProduct[index].startAt,
                          endDate: state.shopProduct[index].endAt,
                        ),
                        const Gap(8),
                      ],
                    );
                  },
                ),
                const SliverToBoxAdapter(
                  child: Gap(20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShopProductsCard extends StatelessWidget {
  const ShopProductsCard({
    super.key,
    this.type = ProductType.bundle,
    this.title = '',
    this.price,
    this.description,
    this.endDate,
    this.startDate,
  });

  final ProductType type;
  final String title;
  final int? price;
  final String? description;
  final DateTime? endDate;
  final DateTime? startDate;

  String get priceInDollars {
    double newPrice = 0.0;
    if (price == null) {
      newPrice = 0.0;
    }
    newPrice = price! / 100;

    return '\$${newPrice.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.amberAccent.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.amber,
              width: 1,
            ),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    type.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (endDate != null)
                    Row(
                      children: [
                        SvgPicture.asset(
                          Assets.images.svg.timerIcon.path,
                          height: 24.0,
                        ),
                        const Gap(4),
                        AppTimer(
                          endDate: endDate!,
                          startDate: startDate,
                        ),
                      ],
                    ),
                ],
              ),
              const Gap(5),
              Row(
                children: <Widget>[
                  SvgPicture.asset(Assets.images.svg.glazeDonutsIcon.path),
                  const Gap(8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    priceInDollars,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900, color: Colors.amber),
                  ),
                ],
              ),
              const Gap(5),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.75,
                    child: Text(
                      description ?? '',
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
              Column(
                children: <Widget>[
                  _buildProductsBenefits(context),
                  const Gap(5),
                  _buildProductsBenefits(context),
                  const Gap(5),
                  _buildProductsBenefits(context),
                ],
              ),
              const Gap(10),
              PrimaryButton(
                label: 'Buy Premium',
                foregroundColor: ColorPallete.backgroundColor,
                backgroundColor: Colors.amber,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row _buildProductsBenefits(BuildContext context) {
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
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Colors.amber),
        ),
      ],
    );
  }
}
