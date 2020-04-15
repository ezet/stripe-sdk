import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import 'progress_bar.dart';

class SetupIntentResponse {
  final String status;
  final String clientSecret;

  SetupIntentResponse(this.status, this.clientSecret);
}

typedef Future<SetupIntentResponse> CreateSetupIntent(String paymentMethodId);

class AddPaymentMethod extends StatefulWidget {
  final Stripe _stripe;
  final CustomerSession _customerSession;
  final CreateSetupIntent _createSetupIntent;
  final bool _useSetupIntent;

  final CardForm form;

  @Deprecated("Experimental. API can change.")
  AddPaymentMethod.withSetupIntent(this._createSetupIntent, {Stripe stripe, this.form})
      : _useSetupIntent = true,
        _customerSession = null,
        _stripe = stripe ?? Stripe.instance;

  @Deprecated("Experimental. API can change.")
  AddPaymentMethod.withoutSetupIntent({CustomerSession customerSession, Stripe stripe, this.form})
      : _useSetupIntent = false,
        _createSetupIntent = null,
        _stripe = stripe ?? Stripe.instance,
        _customerSession = customerSession ?? CustomerSession.instance;

  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState(this.form ?? CardForm());
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final StripeCard _cardData;
  final GlobalKey<FormState> _formKey;
  final CardForm _form;

  _AddPaymentMethodState(this._form)
      : _cardData = _form.card,
        _formKey = _form.formKey;

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

                  var paymentMethod = await this.widget._stripe.api.createPaymentMethodFromCard(_cardData);
                  if (this.widget._useSetupIntent) {
                    final createSetupIntentResponse = await this.widget._createSetupIntent(paymentMethod['id']);

                    if (createSetupIntentResponse.status == 'succeeded') {
                      hideProgressDialog(context);
                      Navigator.pop(context, true);
                      return;
                    }
                    var setupIntent =
                        await this.widget._stripe.confirmSetupIntent(createSetupIntentResponse.clientSecret);

                    hideProgressDialog(context);
                    if (setupIntent['status'] == 'succeeded') {
                      Navigator.pop(context, true);
                    }
                  } else {
                    paymentMethod = await widget._customerSession.attachPaymentMethod(paymentMethod['id']);
                    Navigator.pop(context, true);
                    return;
                  }
                }
              },
            )
          ],
        ),
        body: _form);
  }
}
