import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/stripe_error.dart';

import 'models.dart';

typedef CreateSetupIntent = Future<IntentClientSecret> Function();
typedef CreatePaymentIntent = Future<IntentClientSecret> Function(int amount);

class StripeUiOptions {
  static CreateSetupIntent? createSetupIntent;
  static CreatePaymentIntent? createPaymentIntent;
  static String Function(BuildContext context, String currency, int amount) formatCurrency = _defaultFormatCurrency;

  static Widget Function(BuildContext context, Map<String, dynamic> paymentIntent, void Function()? onPressed)
      payButtonBuilder = _defaultPayButtonBuilder;

  static void Function(BuildContext, Map<String, dynamic>) onPaymentFailed = _defaultOnPaymentFailed;
  static void Function(BuildContext, Map<String, dynamic>) onPaymentSuccess = _defaultOnPaymentSuccess;
  static void Function(BuildContext, StripeApiException) onPaymentError = _defaultOnPaymentError;

  static String defaultWebReturnUrl = "/";
}

String _defaultFormatCurrency(BuildContext context, String currency, int amount) {
  return "${currency.toUpperCase()}${(amount / 100).toStringAsFixed(2)}";
}

Widget _defaultPayButtonBuilder(BuildContext context, Map<String, dynamic> paymentIntent, void Function()? onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text('Pay ${StripeUiOptions.formatCurrency(context, paymentIntent['currency'], paymentIntent['amount'])}'),
  );
}

void _defaultOnPaymentSuccess(BuildContext context, Map<String, dynamic> paymentIntent) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(const SnackBar(content: Text("Payment successfully completed")));
}

void _defaultOnPaymentFailed(BuildContext context, Map<String, dynamic> paymentIntent) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(paymentIntent['last_payment_error']['message'])));
}

void _defaultOnPaymentError(BuildContext context, StripeApiException e) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(e.message)));
}
