import 'dart:async';

import 'package:stripe_sdk/src/ui-flow/model/intent_models.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/ui-flow/service/payment_methods_notifier.dart';

import '../../../stripe_sdk_ui.dart';
import '../../stripe.dart';
import '../../ui/progress_bar.dart';
import '../../ui/widgets/card_form.dart';

/*This class is similar to AddPaymentMethodScreen class except with some modifications, error handling, error displaying with snackbar, usage of SetupIntentModel class model, addition of appBarTitle, appBarElevation, and appBarBackgroundColor properties. I didn't want to change the original file as it breaks few things in the example flutter and the overall flow of the app. Ideally, these 2 classes should be integrated with each other down the line.
*/

typedef SetupIntent = Future<SetupIntentModel> Function();

class AddPaymentMethod extends StatefulWidget {
  /// Used to create a setup intent when required.
  final SetupIntent _setupIntent;

  /// True if a setup intent should be used to set up the payment method.
  final bool _useSetupIntent;

  /// The card form used to collect payment method details.
  final CardForm form;

  //These two properties bellow will provide moderate customization if you want to change the payment method's screen color, evelation, or/and background color.

  ///change app bar elevation
  final double appBarElevation;

  ///change app bar background
  final Color appBarBackgroundColor;

  /// Add a payment method using a Stripe Setup Intent
  AddPaymentMethod.withSetupIntent(this._setupIntent,
      {this.form,
      this.appBarElevation,
      this.appBarBackgroundColor})
      : _useSetupIntent = true;

  /// Add a payment method without using a Stripe Setup Intent - (Not Recommended)
  @Deprecated(
      'Setting up payment methods without a setup intent is not recommended by Stripe. Consider using [withSetupIntent]')
  AddPaymentMethod.withoutSetupIntent(
      {this.form,
      this.appBarElevation,
      this.appBarBackgroundColor})
      : _useSetupIntent = false,
        _setupIntent = null;
  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  CardForm _form;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<SetupIntentModel> _setupIntent;

  @override
  void initState() {
    super.initState();
    _setupIntent = widget._setupIntent();
    _form = widget.form ?? CardForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Add a Card'),
        elevation: widget.appBarElevation,
        backgroundColor: widget.appBarBackgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (_form.formKey.currentState.validate()) {
                _form.formKey.currentState.save();

                try {
                  await showProgressDialog(context);

                  //The _stripe instance should not be null at all, and if its null, an Exception will be thrown. No need to pass it as class parameter
                  var paymentMethod = await Stripe.instance.api
                      .createPaymentMethodFromCard(_form.card);

                  if (widget._useSetupIntent) {
                    final createSetupIntentResponse = await _setupIntent;

                    var setupIntent = await Stripe.instance.confirmSetupIntent(
                        createSetupIntentResponse.clientSecret,
                        paymentMethod['id']);
                    await hideProgressDialog(context);

                    if (setupIntent['status'] == 'succeeded') {
                      // If PaymentMethodsNotifier instance bellow is null, a new object of it is created using the customer session instance. The customer session instance should not be null and if its null, exception will be thrown

                      await PaymentMethodsNotifier.instance.refresh();
                      await Navigator.pop(context, true);
                    } else if (setupIntent['status'] ==
                        'requires_payment_method') {
                      var snackbar = SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Card failed to add',
                                style: TextStyle(),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 7),
                      );
                      await _scaffoldKey.currentState.showSnackBar(snackbar);
                    }
                  } else {
                    await PaymentMethodsNotifier.instance
                        .attachPaymentMethod(paymentMethod['id']);
                    await hideProgressDialog(context);
                    return;
                  }
                } catch (e) {
                  var snackbar = SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.error,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            e.toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 7),
                  );
                  await _scaffoldKey.currentState.showSnackBar(snackbar);
                  await hideProgressDialog(context);
                }
              }
            },
          )
        ],
      ),
      body: _form,
    );
  }
}
