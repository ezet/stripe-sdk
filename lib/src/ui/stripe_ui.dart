import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models.dart';

typedef CreateSetupIntent = Future<IntentResponse> Function();
typedef CreatePaymentIntent = Future<IntentResponse> Function(int amount);

class StripeUiOptions {
  static CreateSetupIntent? createSetupIntent;
  static CreatePaymentIntent? createPaymentIntent;
  static String Function(BuildContext context, String currency, int amount) formatCurrency = _defaultFormatCurrency;

  static Widget Function(BuildContext context, String currency, int total, void Function()? onPressed) payWidgetBuilder = _defaultPayWidgetBuilder;


}

String _defaultFormatCurrency(BuildContext context, String currency, int amount) {
  return (amount / 100).toStringAsFixed(2);
}

Widget _defaultPayWidgetBuilder(BuildContext context, String currency, int total, void Function()? onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text('Pay ${StripeUiOptions.formatCurrency(context, currency, total)}'),
  );
}
