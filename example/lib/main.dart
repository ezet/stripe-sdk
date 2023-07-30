import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk_example/ui/intent_complete_screen.dart';

import 'locator.dart';
import 'network/network_service.dart';
import 'setup_intent_with_sca.dart';
import 'ui/edit_customer_screen.dart';
import 'ui/payment_methods_screen.dart';
import 'ui/payment_screen.dart';

const _stripePublishableKey = 'pk_test_FlC2pf2JCTgKLcgG0aScSQmp00XqfTJL8s';
const _returnUrl = 'stripesdk://demo.stripesdk.ezet.io';
const _returnUrlWeb = 'http://demo.stripesdk.ezet.io';

String getScaReturnUrl() {
  return kIsWeb ? _returnUrlWeb : _returnUrl;
}

void main() async {
  initializeLocator();
  Stripe.init(_stripePublishableKey);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomerSession.initCustomerSession((version) => locator.get<NetworkService>().getEphemeralKey(version));
    final app = MaterialApp(
      title: 'Stripe SDK Demo',
      onUnknownRoute: (RouteSettings settings) {
        final Uri? uri = Uri.tryParse(settings.name!);
        if (uri == null &&
            !uri!.queryParameters.containsKey('setup_intent') &&
            !uri.queryParameters.containsKey('payment_intent')) {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        }
        return MaterialPageRoute(builder: (context) => const IntentCompleteScreen());
      },
      routes: {
        '/': (context) => const HomeScreen(),
        '/3ds/complete': (context) => const IntentCompleteScreen(),
        '/payments': (context) => const PaymentScreen()
      },
      initialRoute: '/',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
    );
    return ChangeNotifierProvider(create: (_) => PaymentMethodStore(), child: app);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe SDK Demo'),
      ),
      body: ListView(children: <Widget>[
        Card(
          child: ListTile(
            title: const Text('Customer Details'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditCustomerScreen())),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Payment Methods Screen'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
              final paymentMethods = Provider.of<PaymentMethodStore>(context, listen: false);
              // ignore: deprecated_member_use
              return PaymentMethodsScreen(paymentMethodStore: paymentMethods);
            })),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Add Payment Method with Setup Intent'),
            // onTap: () => createPaymentMethodWithSetupIntent(context),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Add Payment Method without Setup Intent'),
            // onTap: () => createPaymentMethodWithoutSetupIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Add Stripe Test Card'),
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupIntentWithScaScreen())),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Payments'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentScreen())),
          ),
        ),
      ]),
    );
  }

// void createPaymentMethodWithSetupIntent(BuildContext context) async {
//   final networkService = locator.get<NetworkService>();
//   await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) =>
//               // ignore: deprecated_member_use
//               AddPaymentMethodScreen.withSetupIntent(networkService.createSetupIntent)));
// }

// void createPaymentMethodWithoutSetupIntent(BuildContext context) async {
//   await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) =>
//               // ignore: deprecated_member_use
//               AddPaymentMethodScreen.withoutSetupIntent()));
// }
}
