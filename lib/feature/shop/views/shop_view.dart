import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/config/enum/product_type.dart';
import 'package:glaze/feature/shop/provider/products_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/dialogs/dialogs.dart';
import '../../../gen/fonts.gen.dart';
import '../../templates/loading_layout.dart';
import '../models/shop_product/shop_product.dart';
import '../widgets/shop_products_card.dart';

class ShopView extends HookConsumerWidget {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsNotifierProvider);

    useEffect(() {
      Future.microtask(
        () async {
          ref.read(productsNotifierProvider.notifier).fetchAvailableProducts();
        },
      );
      return;
    }, []);

    ref.listen(productsNotifierProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        final error = next.error;
        final errorBody = error as Exception;

        Dialogs.createContentDialog(
          context,
          title: 'Error',
          content: errorBody.toString(),
          onPressed: () => context.pop(),
        );
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        await ref.refresh(productsNotifierProvider.notifier).fetchAvailableProducts();
      },
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      elevation: 1,
      backgroundColor: Colors.transparent,
      child: RepaintBoundary(
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
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  if (state.shopProduct
                      .where((product) {
                        return product.type == ProductType.featured;
                      })
                      .toList()
                      .isNotEmpty) ...[
                    _buildShopProductLabel(context, label: ProductType.featured.name),
                    _buildProductTyped(
                      state.shopProduct,
                      type: ProductType.featured,
                    ),
                  ],
                  if (state.shopProduct
                      .where((product) {
                        return product.type == ProductType.subscription;
                      })
                      .toList()
                      .isNotEmpty) ...[
                    _buildShopProductLabel(context, label: ProductType.subscription.name),
                    _buildProductTyped(
                      state.shopProduct,
                      type: ProductType.subscription,
                    ),
                  ],
                  if (state.shopProduct
                      .where((product) {
                        return product.type == ProductType.donutBox;
                      })
                      .toList()
                      .isNotEmpty) ...[
                    _buildShopProductLabel(context, label: ProductType.donutBox.name),
                    _buildProductTyped(
                      state.shopProduct,
                      type: ProductType.donutBox,
                    ),
                  ],
                  if (state.shopProduct
                      .where((product) {
                        return product.type == ProductType.donutBox;
                      })
                      .toList()
                      .isNotEmpty) ...[
                    _buildShopProductLabel(context, label: ProductType.bundle.name),
                    _buildProductTyped(
                      state.shopProduct,
                      type: ProductType.bundle,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopProductLabel(BuildContext context, {required String label}) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(10),
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Gap(10),
        ],
      ),
    );
  }

  Widget _buildProductTyped(List<ShopProduct> state, {required ProductType type}) {
    final items = state.where((product) {
      return product.type == type;
    }).toList();

    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ShopProductsCard(
              product: items[index],
            ),
            const Gap(8),
          ],
        );
      },
    );
  }
}
