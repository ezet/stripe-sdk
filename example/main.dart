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
