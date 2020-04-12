import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final StripeCard card = StripeCard();
  final StripeCard cardTwo = StripeCard();

  final cardNumberDecoration = const InputDecoration(
    border: InputBorder.none,
    fillColor: Colors.black,
    filled: true,
    hintStyle: TextStyle(color: Colors.grey),
    hintText: 'Card number',
  );
  final cardNumberTextStyle = const TextStyle(color: Colors.white);

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text('Using Card Form'),
            Form(
              child: CardForm(
                formKey: formKey,
                card: card,
                cardNumberDecoration: cardNumberDecoration,
                cardNumberTextStyle: cardNumberTextStyle,
                cardNumberErrorText: 'Your own message here',
              ),
            ),
            Text('Using Form Text Fields'),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(top: 8),
              child: CardNumberFormField(
                  onChanged: (String number) => cardTwo.number = number,
                  validator: (String text) =>
                      cardTwo.validateNumber() ? null : CardNumberFormField.defaultErrorText,
                  onSaved: (String text) {
                    cardTwo.number = text;
                  },
                  textStyle: cardNumberTextStyle,
                  decoration: cardNumberDecoration),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(top: 8),
              child: CardExpiryFormField(
                initialMonth: 9,
                initialYear: 20,
                onChanged: (int month, int year) {
                  cardTwo.expMonth = month;
                  cardTwo.expYear = year;
                },
                onSaved: (int month, int year) {
                  cardTwo.expMonth = month;
                  cardTwo.expYear = year;
                },
                validator: (String text) =>
                    cardTwo.validateDate() ? null : CardExpiryFormField.defaultErrorText,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(top: 8),
              child: CardCvcFormField(
                onChanged: (String cvc) {
                  cardTwo.cvc = cvc;
                },
                onSaved: (String cvc) {
                  cardTwo.cvc = cvc;
                },
                validator: (String text) =>
                    cardTwo.validateDate() ? null : CardExpiryFormField.defaultErrorText,
              ),
            ),
            RaisedButton(
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  formKey.currentState.save();
                  await StripeApi.instance.createPaymentMethodFromCard(card).then((result) {
                    // Get payment method id
                    print(result['id']);
                  });
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
