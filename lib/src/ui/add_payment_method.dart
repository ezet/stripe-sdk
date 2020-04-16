import 'dart:async';

import 'package:flutter/material.dart';

import '../customer_session.dart';
import '../model/card.dart';
import '../stripe.dart';
import '../widgets/card_form.dart';
import 'models.dart';
import 'progress_bar.dart';

@Deprecated("experimental")
// ignore: deprecated_member_use_from_same_package
typedef Future<IntentResponse> CreateSetupIntent(String paymentMethodId);

@Deprecated("experimental")
class AddPaymentMethodScreen extends StatefulWidget {
  final Stripe _stripe;
  final CustomerSession _customerSession;
  final CreateSetupIntent _createSetupIntent;
  final bool _useSetupIntent;

  final CardForm form;

  AddPaymentMethodScreen.withSetupIntent(this._createSetupIntent, {Stripe stripe, this.form})
      : _useSetupIntent = true,
        _customerSession = null,
        _stripe = stripe ?? Stripe.instance;

  AddPaymentMethodScreen.withoutSetupIntent({CustomerSession customerSession, Stripe stripe, this.form})
      : _useSetupIntent = false,
        _createSetupIntent = null,
        _stripe = stripe ?? Stripe.instance,
        _customerSession = customerSession ?? CustomerSession.instance;

  @override
  _AddPaymentMethodScreenState createState() => _AddPaymentMethodScreenState(this.form ?? CardForm());
}

// ignore: deprecated_member_use_from_same_package
class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final StripeCard _cardData;
  final GlobalKey<FormState> _formKey;
  final CardForm _form;

  _AddPaymentMethodScreenState(this._form)
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
