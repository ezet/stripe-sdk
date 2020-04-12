import 'package:app/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'network/network_service.dart';

class SetupIntentWithScaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe Test Cards'),
      ),
      body: ListView(
        children: <Widget>[
          Card(
              child: ListTile(
            title: Text('pm_card_authenticationRequiredOnSetup'),
            onTap: () async => await completeSetupIntent(context, 'pm_card_authenticationRequiredOnSetup'),
          )),
          Card(
              child: ListTile(
            title: Text('pm_card_authenticationRequired'),
            onTap: () async => await completeSetupIntent(context, 'pm_card_authenticationRequired'),
          ))
        ],
      ),
    );
  }

  completeSetupIntent(BuildContext context, String paymentMethod) async {
    final Stripe stripe = locator.get();
    final NetworkService networkService = locator.get();
    final createSetupIntentResponse = await networkService.createSetupIntent(paymentMethod);
    if (createSetupIntentResponse['status'] == 'succeeded') {
      Navigator.pop(context, true);
      return;
    }
    var setupIntent = await stripe.confirmSetupIntent(createSetupIntentResponse['client_secret']);

    if (setupIntent['status'] == 'succeeded') {
      Navigator.pop(context, true);
      return;
    }
  }
}
