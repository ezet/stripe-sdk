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
    final channel = EventChannel('stripesdk.3ds.stripesdk.io/events');
    StreamSubscription sub;
    sub = channel.receiveBroadcastStream().listen((d) async {
      debugPrint(d.toString());
      sub.cancel();
      final uri = Uri.parse(d);
      final intent = await Stripe.instance.retrievePaymentIntent(
        uri.queryParameters['payment_intent'],
        uri.queryParameters['payment_intent_client_secret'],
      );
      Navigator.pop(context, {'id': intent['id'], 'status': intent['status']});
    });
    debugPrint("url: $url");
    launch(url);
    return Container(
      color: Colors.transparent,
    );
  }
}

Future<Map<String, dynamic>> launch3ds(Map<dynamic, dynamic> action) async {
  final url = action['redirect_to_url']['url'];
  final completer = Completer<Map<String, String>>();
  StreamSubscription sub;
  sub = getUriLinksStream().listen((Uri uri) async {
    debugPrint(uri.toString());
    if (uri.scheme == 'stripesdk' && uri.host == '3ds.stripesdk.io') {
      sub.cancel();
      final intent = await Stripe.instance.retrievePaymentIntent(
        uri.queryParameters['payment_intent'],
        uri.queryParameters['payment_intent_client_secret'],
      );
      completer.complete({'id': intent['id'], 'status': intent['status']});
    }
  });

  debugPrint("url: $url");
  launch(url);
  return completer.future;
}
