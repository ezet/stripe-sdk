import 'dart:async';

import 'package:stripe_sdk/stripe_sdk.dart';

const publishableKey = "my-key";

stripe() async {
  Stripe.init(publishableKey);
  // See Stripe API documentation for details
  final cardData = {};
  await Stripe.instance.createPaymentMethod(cardData);
}

session() {
  CustomerSession.initCustomerSession(
      (apiVersion) => fetchEphemeralKeyFromMyServer(apiVersion));
  CustomerSession.instance.listPaymentMethods();
}

Future<String> fetchEphemeralKeyFromMyServer(String apiVersion) {
  // Send the apiVersion to your server, create the key and return the raw http body.
  return Future.value("Return raw response data");
}

/// https://stripe.com/docs/payments/payment-intents/android
confirmPayment() async {
  // todo
}

/// https://stripe.com/docs/payments/payment-intents/android-manual
authenticatePayment() async {
  final paymentIntentClientSecret = await createAndConfirmPaymentIntent();
  final paymentIntent = await CustomerSession.instance
      .authenticatePaymentIntent(paymentIntentClientSecret);
  if (paymentIntent['status'] == "success") {
    // Authentication was successfull
  } else {
    // See stripe documentation for details on other possible statuses
  }
}

Future<String> createAndConfirmPaymentIntent() {
  // Create and confirm a payment intent.
  // Return the payment intent client secret.
  return Future.value("client_secret");
}
