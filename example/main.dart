import 'dart:async';

import 'package:stripe_sdk/stripe_sdk.dart';

const publishableKey = "my-key";

/// Stripe provides access to general APIs
exampleSetupStripe() async {
  Stripe.init(publishableKey);
  // See Stripe API documentation for details
  final cardData = {};
  await Stripe.instance.createPaymentMethod(cardData);
}

/// CustomerSession provides access to customer specific APIs
exampleSetupSession() {
  CustomerSession.initCustomerSession(
      (apiVersion) => _fetchEphemeralKeyFromMyServer(apiVersion));
  CustomerSession.instance.listPaymentMethods();
}

Future<String> _fetchEphemeralKeyFromMyServer(String apiVersion) {
  // Send the apiVersion to your server, create the key and return the raw http body.
  return Future.value("raw-http-body");
}

/// This method supports the default payment flow as documented by Stripe.
/// https://stripe.com/docs/payments/payment-intents/android
exampleConfirmPayment() async {
  final paymentIntentClientSecret =
      await _createPaymentIntent(Stripe.getReturnUrl());
  final paymentIntent = await CustomerSession.instance
      .confirmPayment(paymentIntentClientSecret, "pm-paymentMethod");
  if (paymentIntent['status'] == 'success') {
    // Confirmation successfull
  } else {
    // Handle other states
  }
}

/// Create payment intent and return the client secret.
/// The `return_url` must be set on the PaymentIntent.
/// https://stripe.com/docs/payments/payment-intents/android#create-payment-intent
Future<String> _createPaymentIntent(String returnUrl) {
  return Future.value("client_secret");
}

/// This method supports the manual payment flow as documented by Stripe.
/// https://stripe.com/docs/payments/payment-intents/android-manual
exampleAuthenticatePayment() async {
  final paymentIntentClientSecret =
      await _createAndConfirmPaymentIntent(Stripe.getReturnUrl());
  final paymentIntent = await CustomerSession.instance
      .authenticatePayment(paymentIntentClientSecret);
  if (paymentIntent['status'] == "success") {
    // Authentication was successfull
  } else {
    // See stripe documentation for details on other possible statuses
  }
}

/// Create and confirm a payment intent on your server.
/// The `returnUrl` must be set on the PaymentIntent by your server.
/// Return the payment intent client secret.
/// https://stripe.com/docs/payments/payment-intents/android-manual#create-and-confirm-payment-intent-manual
Future<String> _createAndConfirmPaymentIntent(String returnUrl) {
  return Future.value("client_secret");
}
