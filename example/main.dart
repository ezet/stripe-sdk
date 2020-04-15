import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

const publishableKey = "my-key";

/// StripeApi provides direct access to Stripe REST API
exampleSetupStripeApi() async {
  StripeApi.init(publishableKey);
  // See Stripe API documentation for details
  final cardData = {};
  await StripeApi.instance.createPaymentMethod(cardData);
}

/// CustomerSession provides access to customer specific APIs
exampleSetupSession() {
  CustomerSession.initCustomerSession(
      (apiVersion) => _fetchEphemeralKeyFromMyServer(apiVersion));
  CustomerSession.instance.listPaymentMethods();
}

Future<String> _fetchEphemeralKeyFromMyServer(String apiVersion) {
  // Send the apiVersion to your server, create the key and return the raw http body.
  return Future.value("raw-http-body");
}

/// This method supports the default payment flow as documented by Stripe.
/// https://stripe.com/docs/payments/payment-intents/android
exampleConfirmPayment() async {
  Stripe.init(publishableKey);
  final paymentIntentClientSecret =
      await _createPaymentIntent(Stripe.instance.getReturnUrlForSca());
  final paymentIntent = await Stripe.instance
      .confirmPayment(paymentIntentClientSecret, paymentMethodId: "pm-paymentMethod");
  if (paymentIntent['status'] == 'success') {
    // Confirmation successfull
  } else {
    // Handle other states
  }
}

/// Create payment intent and return the client secret.
/// The `return_url` must be set on the PaymentIntent.
/// https://stripe.com/docs/payments/payment-intents/android#create-payment-intent
Future<String> _createPaymentIntent(String returnUrl) {
  return Future.value("client_secret");
}

/// This method supports the manual payment flow as documented by Stripe.
/// https://stripe.com/docs/payments/payment-intents/android-manual
exampleAuthenticatePayment() async {
  Stripe.init(publishableKey);
  final paymentIntentClientSecret = await _createAndConfirmPaymentIntent(
      Stripe.instance.getReturnUrlForSca());
  final paymentIntent =
      await Stripe.instance.authenticatePayment(paymentIntentClientSecret);
  if (paymentIntent['status'] == "success") {
    // Authentication was successfull
  } else {
    // See stripe documentation for details on other possible statuses
  }
}

/// Create and confirm a payment intent on your server.
/// The `returnUrl` must be set on the PaymentIntent by your server.
/// Return the payment intent client secret.
/// https://stripe.com/docs/payments/payment-intents/android-manual#create-and-confirm-payment-intent-manual
Future<String> _createAndConfirmPaymentIntent(String returnUrl) {
  return Future.value("client_secret");
}

// UI examples for card form and text form fields

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
    StripeApi.init(publishableKey);
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
              key: formKey,
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
                  validator: (String text) => cardTwo.validateNumber()
                      ? null
                      : CardNumberFormField.defaultErrorText,
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
                onChanged: (int month, int year) {
                  cardTwo.expMonth = month;
                  cardTwo.expYear = year;
                },
                onSaved: (int month, int year) {
                  cardTwo.expMonth = month;
                  cardTwo.expYear = year;
                },
                validator: (String text) => cardTwo.validateDate()
                    ? null
                    : CardExpiryFormField.defaultErrorText,
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
                validator: (String text) => cardTwo.validateDate()
                    ? null
                    : CardExpiryFormField.defaultErrorText,
              ),
            ),
            RaisedButton(
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  formKey.currentState.save();
                  await StripeApi.instance
                      .createPaymentMethodFromCard(card)
                      .then((result) {
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
