import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/components/dialogs/dialogs.dart';
import 'package:glaze/feature/shop/models/shop_product/shop_product.dart';
import 'package:glaze/feature/shop/provider/payment_provider.dart/payment_provider.dart';
import 'package:glaze/feature/shop/widgets/shop_products_card.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/utils/string_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CheckoutView extends ConsumerWidget {
  const CheckoutView({
    super.key,
    required this.product,
  });

  final ShopProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentNotifierProvider);

    ref.listen(paymentNotifierProvider, (prev, next) async {
      if (next.error != null && prev?.error != next.error) {
        final error = next.error as StripeException;

        await Dialogs.createContentDialog(
          context,
          title: 'Payment Error',
          content: error.error.message.toString(),
          onPressed: () => context.pop(),
        );
      }
    });

    return LoadingLayout(
      isLoading: state.isLoading,
      appBar: const AppBarWithBackButton(
        title: Text('Checkout & Payment'),
        centerTitle: true,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ShopProductsCard(
                product: product,
                showBotton: false,
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal: ',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          priceInDollars(product.priceCents),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Taxes: ',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '0.0',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          priceInDollars(product.priceCents),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const Gap(16.0),
                    PrimaryButton(
                      label: 'Pay With Card',
                      onPressed: () async {
                        await ref.read(paymentNotifierProvider.notifier).makePayment(
                              product.priceCents.toString(),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
