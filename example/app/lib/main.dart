import 'package:app/payment_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'locator.dart';

const publishableKey = "my-key";

void main() {
  initializeLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(title: "Stripe SDK Showcase", home: HomeScreen());

    return ChangeNotifierProvider(create: (_) => PaymentMethods(), child: app);
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
            title: Text('Payment Methods'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentMethodsScreen())),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Payments'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentMethodsScreen())),
          ),
        )

      ]),
    );
  }
}
