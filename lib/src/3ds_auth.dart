import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'stripe_api.dart';

class ScaAuth extends StatelessWidget {
  ScaAuth(this.action) : url = action['redirect_to_url']['url'];

  final Map<dynamic, dynamic> action;
  final String url;

  @override
  Widget build(BuildContext context) {
    launch3ds(action).then((it) => Navigator.pop(context, it));
    return Container();
  }
}

/// Launch 3DS in a new browser window.
/// Returns a [Future] with the Stripe PaymentIntent when the user completes authentication.
Future<Map<String, dynamic>> launch3ds(Map<dynamic, dynamic> action,
    {String scheme = 'stripesdk', String host = '3ds.stripesdk.io'}) async {
  final url = action['redirect_to_url']['url'];
  final completer = Completer<Map<String, String>>();
  StreamSubscription sub;
  sub = getUriLinksStream().listen((Uri uri) async {
    debugPrint(uri.toString());
    if (uri.scheme == scheme && uri.host == host) {
      sub.cancel();
      final intent = await Stripe.instance.retrievePaymentIntent(
        uri.queryParameters['payment_intent'],
        uri.queryParameters['payment_intent_client_secret'],
      );
      completer.complete({'id': intent['id'], 'status': intent['status']});
    }
  });

  debugPrint("Launching URL: $url");
  launch(url);
  return completer.future;
}
