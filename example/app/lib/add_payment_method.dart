import 'package:app/locator.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import 'network/network_service.dart';

class AddPaymentMethod extends StatefulWidget {
  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final StripeCard _cardData = StripeCard();
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<Map<String, dynamic>> setupIntent;

  @override
  Widget build(BuildContext context) {
    final stripe = locator.get<Stripe>();
    final networkService = locator.get<NetworkService>();

    return Scaffold(
        appBar: AppBar(
          title: Text('Add payment method'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  showProgressDialog(context);

                  var paymentMethod = await stripe.api.createPaymentMethodFromCard(_cardData);

                  // With or without setupIntent. Stripe recommends using setup intent.
//                  final stripeSession = locator.get<CustomerSession>();
//                  paymentMethod = await stripeSession.attachPaymentMethod(paymentMethod['id']);
                  final createSetupIntentResponse = await networkService.createSetupIntent(paymentMethod['id']);
                  hideProgressDialog(context);

                  if (createSetupIntentResponse['status'] == 'succeeded') {
                    Navigator.pop(context, true);
                    return;
                  }
                  var setupIntent = await stripe.confirmSetupIntent(createSetupIntentResponse['client_secret']);

                  if (setupIntent['status'] == 'succeeded') {
                    Navigator.pop(context, true);
                    return;
                  }
                }
              },
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CardForm(
              card: _cardData,
              formKey: _formKey,
            )));
  }

  void hideProgressDialog(BuildContext context) {
    Navigator.pop(context);
  }

  void showProgressDialog(BuildContext context) {
    showDialog(
        context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));
  }
}
