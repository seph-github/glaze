import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/feature/shop/models/shop_product/shop_product.dart';
import 'package:glaze/feature/shop/services/payment_services.dart';
import 'package:glaze/feature/shop/widgets/shop_products_card.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/utils/price_formatter.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({
    super.key,
    required this.product,
  });

  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    return LoadingLayout(
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
                        await PaymentServices().makePayment(
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
