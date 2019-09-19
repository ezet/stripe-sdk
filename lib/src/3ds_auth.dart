import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'stripe_api.dart';

class ScaAuth extends StatelessWidget {
  ScaAuth(this.action)
      : url = action['redirect_to_url']['url'],
        returnUrl = action['redirect_to_url']['return_url'];

  final Map<dynamic, dynamic> action;
  final String url;
  final String returnUrl;

  @override
  Widget build(BuildContext context) {
    launch3ds(action).then((it) => Navigator.pop(context, it));
    return Container();
  }
}

/// Launch 3DS in a new browser window.
/// Returns a [Future] with the Stripe PaymentIntent when the user completes or cancels authentication.
Future<Map<String, dynamic>> launch3ds(Map<dynamic, dynamic> action) async {
  final url = action['redirect_to_url']['url'];
  final returnUrl = Uri.parse(action['redirect_to_url']['return_url']);
  final completer = Completer<Map<String, dynamic>>();
  StreamSubscription sub;
  sub = getUriLinksStream().listen((Uri uri) async {
    debugPrint(uri.toString());
    if (uri.scheme == returnUrl.scheme &&
        uri.host == returnUrl.host &&
        uri.queryParameters['requestId'] ==
            returnUrl.queryParameters['requestId']) {
      await sub.cancel();
      final intent = await Stripe.instance.retrievePaymentIntent(
        uri.queryParameters['payment_intent_client_secret'],
      );
      completer.complete(intent);
    }
  });

  debugPrint("Launching URL: $url");
  await launch(url);
  return completer.future;
}
