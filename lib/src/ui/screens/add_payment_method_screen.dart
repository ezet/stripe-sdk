import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/ui/stores/payment_method_store.dart';

import '../../models/card.dart';
import '../../stripe.dart';
import '../models.dart';
import '../progress_bar.dart';
import '../widgets/card_form.dart';

///
@Deprecated("Experimental")
// ignore: deprecated_member_use_from_same_package
typedef Future<IntentResponse> CreateSetupIntent();

/// A screen that collects, creates and attaches a payment method to a stripe customer.
///
/// Payment methods can be created with and without a Setup Intent. Using a Setup Intent is highly recommended.
///
@Deprecated("Experimental")
class AddPaymentMethodScreen extends StatefulWidget {
  final Stripe _stripe;

  /// Used to create a setup intent when required.
  final CreateSetupIntent _createSetupIntent;

  /// True if a setup intent should be used to set up the payment method.
  final bool _useSetupIntent;

  /// The payment method store used to manage payment methods.
  final PaymentMethodStore paymentMethodStore;

  /// The card form used to collect payment method details.
  final CardForm form;

  /// Add a payment method using a Stripe Setup Intent
  AddPaymentMethodScreen.withSetupIntent(this._createSetupIntent, this.paymentMethodStore, {Stripe stripe, this.form})
      : _useSetupIntent = true,
        _stripe = stripe ?? Stripe.instance;

  /// Add a payment method without using a Stripe Setup Intent
  @Deprecated(
      "Setting up payment methods without a setup intent is not recommended by Stripe. Consider using [withSetupIntent]")
  AddPaymentMethodScreen.withoutSetupIntent(this.paymentMethodStore, {Stripe stripe, this.form})
      : _useSetupIntent = false,
        _createSetupIntent = null,
        _stripe = stripe ?? Stripe.instance;

  @override
  _AddPaymentMethodScreenState createState() => _AddPaymentMethodScreenState(this.form ?? CardForm());
}

// ignore: deprecated_member_use_from_same_package
class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final StripeCard _cardData;
  final GlobalKey<FormState> _formKey;
  final CardForm _form;
  Future<IntentResponse> setupIntent;

  _AddPaymentMethodScreenState(this._form)
      : _cardData = _form.card,
        _formKey = _form.formKey;

  @override
  void initState() {
    setupIntent = widget._createSetupIntent();
    super.initState();
  }

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
                    final createSetupIntentResponse = await this.setupIntent;
                    var setupIntent = await this.widget._stripe.confirmSetupIntentWithPaymentMethod(
                        createSetupIntentResponse.clientSecret, paymentMethod['id']);

                    hideProgressDialog(context);
                    if (setupIntent['status'] == 'succeeded') {
                      Navigator.pop(context, true);
                    }
                  } else {
                    paymentMethod = await widget.paymentMethodStore.attachPaymentMethod(paymentMethod['id']);
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
