import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stripe_api/src/stripe_api.dart';
import 'package:url_launcher/url_launcher.dart';

class ScaAuth extends StatelessWidget {
  ScaAuth(this.action) : url = action['redirect_to_url']['url'];

  final Map<dynamic, dynamic> action;
  final String url;

  @override
  Widget build(BuildContext context) {
    final channel = EventChannel('poc.3ds.glappen.io/events');
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

    launch(url);
    return Container();
  }

  String getClientSecret(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters['client_secret'];
  }
}
