

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/ui/stores/payment_method_store.dart';

import '../../models/card.dart';
import '../../stripe.dart';
import '../models.dart';
import '../progress_bar.dart';
import '../widgets/card_form.dart';

///
typedef CreateSetupIntent = Future<IntentResponse> Function();

/// A screen that collects, creates and attaches a payment method to a stripe customer.
///
/// Payment methods can be created with and without a Setup Intent. Using a Setup Intent is highly recommended.
///
class AddPaymentMethodScreen extends StatefulWidget {
  final Stripe _stripe;

  /// Used to create a setup intent when required.
  final CreateSetupIntent? _createSetupIntent;

  /// True if a setup intent should be used to set up the payment method.
  final bool _useSetupIntent;

  /// The payment method store used to manage payment methods.
  final PaymentMethodStore _paymentMethodStore;

  /// The card form used to collect payment method details.
  final CardForm? form;

  /// Custom Title for the screen
  final String title;
  static const String _defaultTitle = 'Add payment method';

  /// Add a payment method using a Stripe Setup Intent
  AddPaymentMethodScreen.withSetupIntent(this._createSetupIntent,
      {PaymentMethodStore? paymentMethodStore, Stripe? stripe, this.form, this.title = _defaultTitle})
      : _useSetupIntent = true,
        _paymentMethodStore = paymentMethodStore ?? PaymentMethodStore.instance,
        _stripe = stripe ?? Stripe.instance;

  /// Add a payment method without using a Stripe Setup Intent
  @Deprecated(
      'Setting up payment methods without a setup intent is not recommended by Stripe. Consider using [withSetupIntent]')
  AddPaymentMethodScreen.withoutSetupIntent({PaymentMethodStore? paymentMethodStore, Stripe? stripe, this.form, this.title = _defaultTitle})
      : _useSetupIntent = false,
        _createSetupIntent = null,
        _paymentMethodStore = paymentMethodStore ?? PaymentMethodStore.instance,
        _stripe = stripe ?? Stripe.instance;

  @override
  _AddPaymentMethodScreenState createState() => _AddPaymentMethodScreenState(form ?? CardForm());
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final StripeCard _cardData;
  final GlobalKey<FormState> _formKey;
  final CardForm _form;

  late IntentResponse setupIntent;

  _AddPaymentMethodScreenState(this._form)
      : _cardData = _form.card,
        _formKey = _form.formKey;

  @override
  void initState() {
    _createSetupIntent();
    super.initState();
  }

  void _createSetupIntent() async {
    if (widget._useSetupIntent) setupIntent = await widget._createSetupIntent!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                FormState? formState = _formKey.currentState;
                if (formState?.validate() ?? false) {
                  formState!.save();

                  showProgressDialog(context);

                  var paymentMethod = await widget._stripe.api.createPaymentMethodFromCard(_cardData);
                  if (widget._useSetupIntent) {
                    final createSetupIntentResponse = this.setupIntent;
                    final setupIntent = await widget._stripe.confirmSetupIntent(
                      createSetupIntentResponse.clientSecret,
                      paymentMethod['id'],
                    );

                    hideProgressDialog(context);
                    if (setupIntent['status'] == 'succeeded') {
                      /// A new payment method has been attached, so refresh the store.
                      // ignore: unawaited_futures
                      widget._paymentMethodStore.refresh();
                      Navigator.pop(context, true);
                      return;
                    }
                  } else {
                    paymentMethod = await (widget._paymentMethodStore.attachPaymentMethod(paymentMethod['id']) as FutureOr<Map<String, dynamic>>);
                    hideProgressDialog(context);
                    Navigator.pop(context, true);
                    return;
                  }
                  Navigator.pop(context, false);
                }
              },
            )
          ],
        ),
        body: _form);
  }
}
