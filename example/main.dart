import 'dart:async';

import 'package:stripe_sdk/stripe_sdk.dart';

const publishableKey = "my-key";

/// Stripe provides access to general APIs
setupStripe() async {
  Stripe.init(publishableKey);
  // See Stripe API documentation for details
  final cardData = {};
  await Stripe.instance.createPaymentMethod(cardData);
}

/// CustomerSession provides access to customer specific APIs
setupSession() {
  CustomerSession.initCustomerSession(
      (apiVersion) => _fetchEphemeralKeyFromMyServer(apiVersion));
  CustomerSession.instance.listPaymentMethods();
}

Future<String> _fetchEphemeralKeyFromMyServer(String apiVersion) {
  // Send the apiVersion to your server, create the key and return the raw http body.
  return Future.value("raw-http-body");
}

/// https://stripe.com/docs/payments/payment-intents/android
confirmPayment() async {
  final paymentIntentClientSecret = await _createPaymentIntent();
  final paymentIntent = await CustomerSession.instance
      .confirmPayment(paymentIntentClientSecret, "pm-paymentMethod");
  if (paymentIntent['status'] == 'success') {
    // Confirmation successfull
  } else {
    // Handle other states
  }
}


/// Create payment intent with automatic confirmation and return the client secret.
/// The `return_url` must be set to `stripesdk://3ds.stripesdk.io`
Future<String> _createPaymentIntent() {
  return Future.value("client_secret");
}

/// https://stripe.com/docs/payments/payment-intents/android-manual
authenticatePayment() async {
  final paymentIntentClientSecret = await _createAndConfirmPaymentIntent();
  final paymentIntent = await CustomerSession.instance
      .authenticatePayment(paymentIntentClientSecret);
  if (paymentIntent['status'] == "success") {
    // Authentication was successfull
  } else {
    // See stripe documentation for details on other possible statuses
  }
}


/// Create and confirm a payment intent on your server.
/// The `return_url` must be set to `stripesdk://3ds.stripesdk.io`
/// Return the payment intent client secret.
Future<String> _createAndConfirmPaymentIntent() {
  return Future.value("client_secret");
}
