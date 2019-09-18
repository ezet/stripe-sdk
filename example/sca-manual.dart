import 'dart:async';

import 'package:stripe_sdk/stripe_sdk.dart';

/// https://stripe.com/docs/payments/payment-intents/android-manual
authenticatePayment() async {
  final paymentIntentClientSecret = await createAndConfirmPaymentIntent();
  final paymentIntent = await CustomerSession.instance
      .authenticatePayment(paymentIntentClientSecret);
  if (paymentIntent['status'] == "success") {
    // Authentication was successfull
  } else {
    // See stripe documentation for details on other possible statuses
  }
}

Future<String> createAndConfirmPaymentIntent() {
  // Create and confirm a payment intent on your server.
  // The `return_url` must be set to `stripesdk://3ds.stripesdk.io`
  // Return the payment intent client secret.
  return Future.value("client_secret");
}
