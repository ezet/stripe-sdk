import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import '../locator.dart';
import '../network/network_service.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments'),
      ),
      body: ListView(children: <Widget>[
        Card(
          child: ListTile(
            title: Text('Automatic confirmation (3DS2)'),
            onTap: () => createAutomaticPaymentIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Manual confirmation (3DS2)'),
            onTap: () => createAutomaticPaymentIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Checkout (WIP)'),
            onTap: () => checkout(context),
          ),
        ),
      ]),
    );
  }

  Future checkout(BuildContext context) {
    var items = [
      CheckoutItem(
        name: "Book",
        price: 40000,
        currency: "\$",
      ),
      CheckoutItem(
        name: "CD",
        price: 10000,
        currency: "\$",
      )
    ];
    final NetworkService networkService = locator.get();
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CheckoutScreen(
        title: "Checkout",
        items: items,
//        paymentMethods: paymentMethods.paymentMethods.map((e) => PaymentMethod(e.id, e.last4)),
        createPaymentIntent: networkService.createAutomaticPaymentIntent,
      );
    }));
  }

  void createAutomaticPaymentIntent(BuildContext context) async {
    final NetworkService networkService = locator.get();
    final response = await networkService.createAutomaticPaymentIntent(10000);
    if (response.status == "succeeded") {
      // TODO: success
      debugPrint("Success before authentication.");
      return;
    }
    final result = await Stripe.instance
        .confirmPayment(response.clientSecret, paymentMethodId: "pm_card_threeDSecure2Required");
    if (result['status'] == "succeeded") {
      // TODO: success
      debugPrint("Success after authentication.");
      return;
    } else {
      debugPrint("Error");
    }
  }

  void createManualPaymentIntent(BuildContext context) async {
    final NetworkService networkService = locator.get();
    final response = await networkService.createManualPaymentIntent(10000, "pm_card_threeDSecure2Required");
    if (response['status'] == "succeeded") {
      // TODO: success
      debugPrint("Success before authentication.");
      return;
    }
    final result = await Stripe.instance.authenticatePayment(response['clientSecret']);
    if (result['status'] == "requires_confirmation") {
      // TODO: make call to server to confirm
      debugPrint("Success after authentication.");
      return;
    } else {
      debugPrint("Error");
    }
  }
}
