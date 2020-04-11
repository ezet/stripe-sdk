import 'package:app/payment_methods.dart';
import 'package:flutter/material.dart';

import 'locator.dart';

const publishableKey = "my-key";

void main() {
  initializeLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Stripe SDK Showcase", home: HomeScreen());
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
        )
      ]),
    );
  }
}
