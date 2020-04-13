import 'package:app/network/network_service.dart';
import 'package:app/payment_methods.dart';
import 'package:app/setup_intent_with_sca.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import 'locator.dart';

void main() {
  initializeLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(title: "Stripe SDK Showcase", home: HomeScreen());

    return ChangeNotifierProvider(create: (_) => PaymentMethodsData(), child: app);
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe SDK Demo'),
      ),
      body: ListView(children: <Widget>[
        Card(
          child: ListTile(
            title: Text('List Payment Methods'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentMethodsScreen())),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Add Payment Method with Setup Intent'),
            onTap: () async => await this.createPaymentMethodWithSetupIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Add Payment Method without Setup Intent'),
            onTap: () async => await this.createPaymentMethodWithoutSetupIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Add Stripe Test Card'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SetupIntentWithScaScreen())),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Payment Intent with SCA/3DS'),
            onTap: () async => await this.createPaymentMethodWithoutSetupIntent(context),
          ),
        )
      ]),
    );
  }

  void createPaymentMethodWithSetupIntent(BuildContext context) async {
    final networkService = locator.get<NetworkService>();
    final stripe = locator.get<Stripe>();
    final paymentMethods = Provider.of<PaymentMethodsData>(context, listen: false);
    final added = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPaymentMethod.withSetupIntent(networkService.createSetupIntent, stripe: stripe)));
    if (added == true) await paymentMethods.refresh();
  }

  void createPaymentMethodWithoutSetupIntent(BuildContext context) async {
    final stripe = locator.get<Stripe>();
    final customerSession = locator.get<CustomerSession>();
    final paymentMethods = Provider.of<PaymentMethodsData>(context, listen: false);
    final added = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddPaymentMethod.withoutSetupIntent(customerSession: customerSession, stripe: stripe)));
    if (added == true) await paymentMethods.refresh();
  }
}
