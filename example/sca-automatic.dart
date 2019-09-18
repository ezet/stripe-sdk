import 'dart:async';

import 'package:stripe_sdk/src/stripe_api.dart';

/// https://stripe.com/docs/payments/payment-intents/android
confirmPayment() async {
  final paymentIntentClientSecret = await createPaymentIntent();
  final paymentIntent = await CustomerSession.instance
      .confirmPayment(paymentIntentClientSecret, "pm-paymentMethod");
  if (paymentIntent['status'] == 'success') {
    // Confirmation successfull
  } else {
    // Handle other states
  }
}

Future<String> createPaymentIntent() {
  // Create payment intent with automatic confirmation and return the client secret.
  // The `return_url` must be set to `stripesdk://3ds.stripesdk.io`
  return Future.value("client_secret");
}
