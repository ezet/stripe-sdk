import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'locator.dart';
import 'network/network_service.dart';
import 'ui/progress_bar.dart';

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
          )),
          Card(
              child: ListTile(
            title: Text('pm_card_authenticationRequiredChargeDeclinedInsufficientFunds'),
            onTap: () async =>
                await completeSetupIntent(context, 'pm_card_authenticationRequiredChargeDeclinedInsufficientFunds'),
          )),
        ],
      ),
    );
  }

  completeSetupIntent(BuildContext context, String paymentMethod) async {
    final Stripe stripe = Stripe.instance;
    final NetworkService networkService = locator.get();
    showProgressDialog(context);
    final createSetupIntentResponse = await networkService.createSetupIntent();

    var setupIntent = await stripe.confirmSetupIntentWithPaymentMethod(createSetupIntentResponse.clientSecret, paymentMethod);
    hideProgressDialog(context);

    if (setupIntent['status'] == 'succeeded') {
      Navigator.pop(context, true);
//      await paymentMethods.refresh();
    } else {
      Navigator.pop(context, false);
    }
  }
}
