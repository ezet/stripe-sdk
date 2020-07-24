import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import 'locator.dart';
import 'network/network_service.dart';
import 'setup_intent_with_sca.dart';
import 'ui/edit_customer_screen.dart';
import 'ui/payment_screen.dart';

const _stripePublishableKey = 'pk_test_FlC2pf2JCTgKLcgG0aScSQmp00XqfTJL8s';
const _returnUrl = 'stripesdk://demo.stripesdk.ezet.io';

void main() {
  initializeLocator();
  Stripe.init(_stripePublishableKey, returnUrlForSca: _returnUrl);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CustomerSession.initCustomerSession((version) => locator.get<NetworkService>().getEphemeralKey(version));
    final app = MaterialApp(title: 'Stripe SDK Demo', home: HomeScreen());
    return ChangeNotifierProvider(create: (_) => PaymentMethodStore(), child: app);
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
            title: Text('Customer Details'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditCustomerScreen())),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Payment Methods Screen'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
              final paymentMethods = Provider.of<PaymentMethodStore>(context, listen: false);
              // ignore: deprecated_member_use
              return PaymentMethodsScreen(
                  createSetupIntent: locator.get<NetworkService>().createSetupIntent,
                  paymentMethodStore: paymentMethods);
            })),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Add Payment Method with Setup Intent'),
            onTap: () async => await createPaymentMethodWithSetupIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Add Payment Method without Setup Intent'),
            onTap: () async => await createPaymentMethodWithoutSetupIntent(context),
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
            title: Text('Payments'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen())),
          ),
        ),
      ]),
    );
  }

  void createPaymentMethodWithSetupIntent(BuildContext context) async {
    final networkService = locator.get<NetworkService>();
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                // ignore: deprecated_member_use
                AddPaymentMethodScreen.withSetupIntent(networkService.createSetupIntent)));
  }

  void createPaymentMethodWithoutSetupIntent(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                // ignore: deprecated_member_use
                AddPaymentMethodScreen.withoutSetupIntent()));
  }
}
