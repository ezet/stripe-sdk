import 'package:app/network/network_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

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
            title: Text('Perform Charge (VISA, Payment Intent)'),
            onTap: () => createPaymentIntent(context),
          ),
        ),
      ]),
    );
  }

  void createPaymentIntent(BuildContext context) async {
    final NetworkService networkService = locator.get();
    await networkService.createPaymentIntent(10000, "pm_card_visa");
  }
}
