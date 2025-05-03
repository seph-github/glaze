import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/feature/shop/provider/products_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../gen/fonts.gen.dart';
import '../../templates/loading_layout.dart';
import '../widgets/shop_products_card.dart';

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
        await ref.refresh(productsNotifierProvider.notifier).fetchAvailableProducts();
      },
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      elevation: 1,
      backgroundColor: Colors.transparent,
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
                          product: state.shopProduct[index],
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
