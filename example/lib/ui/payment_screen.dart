import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk_example/network/network_service.dart';

import '../locator.dart';
import 'checkout_page.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: ListView(children: <Widget>[
        Card(
          child: ListTile(
            title: const Text('Automatic confirmation (3DS2)'),
            onTap: () => createAutomaticPaymentIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Manual confirmation (3DS2)'),
            onTap: () => createAutomaticPaymentIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Checkout (WIP)'),
            onTap: () => checkout(context),
          ),
        ),
      ]),
    );
  }

  Future checkout(BuildContext context) {
    final networkService = locator.get<NetworkService>();
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      // ignore: deprecated_member_use
      return CheckoutPage(
//        paymentMethods: paymentMethods.paymentMethods.map((e) => PaymentMethod(e.id, e.last4)),
        createPaymentIntent: networkService.createAutomaticPaymentIntent,
      );
    }));
  }

  void createAutomaticPaymentIntent(BuildContext context) async {
    final networkService = locator.get<NetworkService>();
    final response = await networkService.createAutomaticPaymentIntent();
    if (response.status == 'succeeded') {
      // TODO: success
      debugPrint('Success before authentication.');
      return;
    }
    final result = await Stripe.instance.confirmPayment(
      response.clientSecret,
      context,
      paymentMethodId: 'pm_card_threeDSecure2Required',
    );
    if (result['status'] == 'succeeded') {
      // TODO: success
      debugPrint('Success after authentication.');
      return;
    } else {
      debugPrint('Error');
    }
  }

  void createManualPaymentIntent(BuildContext context) async {
    final networkService = locator.get<NetworkService>();
    final Map response = await (networkService.createManualPaymentIntent(
      10000,
      'pm_card_threeDSecure2Required',
      Stripe.instance.getReturnUrlForSca(webReturnUrl: '/'),
    ) as FutureOr<Map<dynamic, dynamic>>);
    if (response['status'] == 'succeeded') {
      // TODO: success
      debugPrint('Success before authentication.');
      return;
    }
    final result = await Stripe.instance.authenticatePayment(response['clientSecret'], context);
    if (result['status'] == 'requires_confirmation') {
      // TODO: make call to server to confirm
      debugPrint('Success after authentication.');
      return;
    } else {
      debugPrint('Error');
    }
  }

  const PaymentScreen({Key? key}) : super(key: key);
}
