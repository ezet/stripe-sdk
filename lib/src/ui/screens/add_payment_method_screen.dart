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
  late final CreateSetupIntent _createSetupIntent;

  /// True if a setup intent should be used to set up the payment method.
  final bool _useSetupIntent;

  /// The payment method store used to manage payment methods.
  final PaymentMethodStore _paymentMethodStore;

  /// The card form used to collect payment method details.
  final CardForm _form;

  /// Custom Title for the screen
  final String title;
  static const String _defaultTitle = 'Add payment method';

  static Route<String?> routeWithoutSetupIntent(
      {PaymentMethodStore? paymentMethodStore, Stripe? stripe, CardForm? form, String title = _defaultTitle}) {
    return MaterialPageRoute(
      // ignore: deprecated_member_use_from_same_package
      builder: (context) => AddPaymentMethodScreen.withoutSetupIntent(
        paymentMethodStore: paymentMethodStore,
        stripe: stripe,
        form: form,
        title: title,
      ),
    );
  }

  static Route<String?> routeWithSetupIntent(CreateSetupIntent createSetupIntent,
      {PaymentMethodStore? paymentMethodStore, Stripe? stripe, CardForm? form, String title = _defaultTitle}) {
    return MaterialPageRoute(
      builder: (context) => AddPaymentMethodScreen.withSetupIntent(
        createSetupIntent,
        paymentMethodStore: paymentMethodStore,
        stripe: stripe,
        form: form,
        title: title,
      ),
    );
  }

  /// Add a payment method using a Stripe Setup Intent
  AddPaymentMethodScreen.withSetupIntent(this._createSetupIntent,
      {PaymentMethodStore? paymentMethodStore, Stripe? stripe, CardForm? form, this.title = _defaultTitle})
      : _useSetupIntent = true,
        _form = form ?? CardForm(),
        _paymentMethodStore = paymentMethodStore ?? PaymentMethodStore.instance,
        _stripe = stripe ?? Stripe.instance;

  /// Add a payment method without using a Stripe Setup Intent
  @Deprecated(
      'Setting up payment methods without a setup intent is not recommended by Stripe. Consider using [withSetupIntent]')
  AddPaymentMethodScreen.withoutSetupIntent(
      {PaymentMethodStore? paymentMethodStore, Stripe? stripe, CardForm? form, this.title = _defaultTitle})
      : _useSetupIntent = false,
        _form = form ?? CardForm(),
        _paymentMethodStore = paymentMethodStore ?? PaymentMethodStore.instance,
        _stripe = stripe ?? Stripe.instance;

  @override
  _AddPaymentMethodScreenState createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  late final StripeCard _cardData;
  late final GlobalKey<FormState> _formKey;

  late IntentResponse setupIntent;

  @override
  void initState() {
    _createSetupIntent();
    _cardData = widget._form.card;
    _formKey = widget._form.formKey;
    super.initState();
  }

  Future<void> _createSetupIntent() async {
    if (widget._useSetupIntent) setupIntent = await widget._createSetupIntent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                final formState = _formKey.currentState;
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
                      widget._paymentMethodStore.refresh();
                      Navigator.pop(context, true);
                      return;
                    }
                  } else {
                    paymentMethod = await (widget._paymentMethodStore.attachPaymentMethod(paymentMethod['id'])
                        as FutureOr<Map<String, dynamic>>);
                    hideProgressDialog(context);
                    Navigator.pop(context, paymentMethod['id']);
                    return;
                  }
                  Navigator.pop(context, null);
                }
              },
            )
          ],
        ),
        body: widget._form);
  }
}
