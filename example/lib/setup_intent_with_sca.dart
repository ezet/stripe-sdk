import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:stripe_sdk_example/network/network_service.dart';

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
    final NetworkService networkService = locator.get();
    showProgressDialog(context);
    RouteSettings? routeSettings = ModalRoute.of(context)?.settings;
    final createSetupIntentResponse = await networkService.createSetupIntentWithPaymentMethod(
      paymentMethod,
      Stripe.instance.getReturnUrlForSca(webReturnPath: routeSettings?.name),
    );
    final PaymentMethodStore paymentMethods = Provider.of(context, listen: false);
    if (createSetupIntentResponse.status == 'succeeded') {
      hideProgressDialog(context);
      Navigator.pop(context, true);

      /// A new payment method has been attached, so refresh the store
      var _ = paymentMethods.refresh();

      return;
    }
    final setupIntent = await stripe.authenticateSetupIntent(createSetupIntentResponse.clientSecret,
        webReturnPath: routeSettings?.name, context: context);
    hideProgressDialog(context);
    Navigator.pop(context, setupIntent['status'] == 'succeeded');
  }
}
