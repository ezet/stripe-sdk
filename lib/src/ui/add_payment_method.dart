import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import 'progress_bar.dart';

typedef Future<Map> createSetupIntent(String paymentMethodId);
typedef Future<Map> confirmSetupIntent(String clientSecret);

class AddPaymentMethod extends StatefulWidget {
  final Stripe stripe;
  final CustomerSession customerSession;
  final Future<Map> Function(String paymentMethodId) createSetupIntent;
  final bool useSetupIntent;

//  final CardForm form;

  AddPaymentMethod.withSetupIntent(this.createSetupIntent, {this.stripe})
      : useSetupIntent = true,
        customerSession = null;

  AddPaymentMethod.withoutSetupIntent(this.customerSession, {this.stripe})
      : useSetupIntent = false,
        createSetupIntent = null;

  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final StripeCard _cardData = StripeCard();
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<Map<String, dynamic>> setupIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add payment method'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  showProgressDialog(context);

                  var paymentMethod = await this.widget.stripe.api.createPaymentMethodFromCard(_cardData);
                  if (this.widget.useSetupIntent) {
                    final createSetupIntentResponse = await this.widget.createSetupIntent(paymentMethod['id']);

                    if (createSetupIntentResponse['status'] == 'succeeded') {
                      hideProgressDialog(context);
                      Navigator.pop(context, true);
                      return;
                    }
                    var setupIntent =
                        await this.widget.stripe.confirmSetupIntent(createSetupIntentResponse['client_secret']);

                    hideProgressDialog(context);
                    if (setupIntent['status'] == 'succeeded') {
                      Navigator.pop(context, true);
                    }
                  } else {
                    paymentMethod = await widget.customerSession.attachPaymentMethod(paymentMethod['id']);
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


}

