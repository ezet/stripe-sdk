import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'locator.dart';
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

  Future<void> completeSetupIntent(BuildContext context, String paymentMethod) async {
    final stripe = Stripe.instance;
    final networkService = locator.get();
    showProgressDialog(context);
    final createSetupIntentResponse = await networkService.createSetupIntentWithPaymentMethod(paymentMethod);
    final paymentMethods = Provider.of(context, listen: false);
    if (createSetupIntentResponse.status == 'succeeded') {
      hideProgressDialog(context);
      Navigator.pop(context, true);

      /// A new payment method has been attached, so refresh the store
      // ignore: unawaited_futures
      paymentMethods.refresh();

      return;
    }
    var setupIntent = await stripe.authenticateSetupIntent(createSetupIntentResponse.clientSecret);
    hideProgressDialog(context);
    Navigator.pop(context, setupIntent['status'] == 'succeeded');
  }
}
