import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentServices {
  const PaymentServices._();

  static Future<void> makePayment(String amount) async {
    try {
      const merchantDisplayName = String.fromEnvironment('appName', defaultValue: '');

      final SupabaseClient supabase = Supabase.instance.client;
      final response = await supabase.functions.invoke('create_payment_intent', body: {
        'amount': amount,
      });
      final data = response.data;

      final clientSecret = data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      print('✅ Payment successful!');
    } catch (e) {
      print('❌ Payment failed: $e');
      rethrow;
    }
  }
}
