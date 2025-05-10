import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentServices {
  Future<void> makePayment(String amount) async {
    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final response = await supabase.functions.invoke('create_payment_intent', body: {
        'amount': amount,
      });
      final data = response.data;

      print('data $data');

      final clientSecret = data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Glaze',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      print('✅ Payment successful!');
    } catch (e) {
      print('❌ Payment failed: $e');
    }
  }
}
