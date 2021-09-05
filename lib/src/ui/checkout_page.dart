import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/stripe_error.dart';
import 'package:stripe_sdk/src/ui/stripe_ui.dart';

import '../stripe.dart';
import 'models.dart';
import 'progress_bar.dart';
import 'stores/payment_method_store.dart';
import 'widgets/payment_method_selector.dart';

class CheckoutPage extends StatefulWidget {
  final Future<IntentClientSecret> Function() createPaymentIntent;
  final void Function(BuildContext context, Map<String, dynamic> paymentIntent) onPaymentSuccess;
  final void Function(BuildContext context, Map<String, dynamic> paymentIntent) onPaymentFailed;
  final void Function(BuildContext context, StripeApiException e) onPaymentError;

  CheckoutPage({
    Key? key,
    required this.createPaymentIntent,
    void Function(BuildContext context, Map<String, dynamic> paymentIntent)? onPaymentSuccess,
    void Function(BuildContext context, Map<String, dynamic> paymentIntent)? onPaymentFailed,
    void Function(BuildContext, StripeApiException)? onPaymentError,
  })  : onPaymentSuccess = onPaymentSuccess ?? StripeUiOptions.onPaymentSuccess,
        onPaymentFailed = onPaymentFailed ?? StripeUiOptions.onPaymentFailed,
        onPaymentError = onPaymentError ?? StripeUiOptions.onPaymentError,
        super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

// ignore: deprecated_member_use_from_same_package
class _CheckoutPageState extends State<CheckoutPage> {
  final PaymentMethodStore paymentMethodStore = PaymentMethodStore.instance;

  String? _selectedPaymentMethod;
  late Future<IntentClientSecret> _clientSecretFuture;
  late Future<Map<String, dynamic>> paymentIntentFuture;

  @override
  void initState() {
    _clientSecretFuture = widget.createPaymentIntent();
    paymentIntentFuture =
        _clientSecretFuture.then((value) => Stripe.instance.api.retrievePaymentIntent(value.clientSecret));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Center(
          child: PaymentMethodSelector(
              paymentMethodStore: paymentMethodStore,
              initialPaymentMethodId: null,
              onChanged: (value) => setState(() {
                    _selectedPaymentMethod = value;
                  })),
        ),
        Flexible(
          child: FutureBuilder<Map<String, dynamic>>(
              future: paymentIntentFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: StripeUiOptions.payButtonBuilder(
                        context,
                        snapshot.data!,
                        _selectedPaymentMethod == null
                            ? null
                            : _createAttemptPaymentFunction(context, _clientSecretFuture)),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        )
      ],
    );
  }

  void Function() _createAttemptPaymentFunction(BuildContext context, Future<IntentClientSecret> paymentIntentFuture) {
    return () async {
      showProgressDialog(context);
      final initialPaymentIntent = await paymentIntentFuture;
      try {
        final confirmedPaymentIntent = await Stripe.instance
            .confirmPayment(initialPaymentIntent.clientSecret, context, paymentMethodId: _selectedPaymentMethod);
        hideProgressDialog(context);
        if (confirmedPaymentIntent['status'] == 'succeeded') {
          widget.onPaymentSuccess(context, confirmedPaymentIntent);
        } else {
          widget.onPaymentFailed(context, confirmedPaymentIntent);
        }
      } catch (e) {
        hideProgressDialog(context);
        if (e is StripeApiException) {
          widget.onPaymentError(context, e);
        } else {
          debugPrint(e.toString());
          rethrow;
        }
      }
    };
  }
}

@Deprecated('Experimental')
class CheckoutItemList extends StatelessWidget {
  final List<CheckoutItem> items;
  final int total;

  const CheckoutItemList({Key? key, required this.items, required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = List<Widget>.from(items);
    list.add(CheckoutSumItem(
      total: total,
      currency: items.first.currency,
    ));
    return ListView(
      shrinkWrap: true,
      children: list,
    );
  }
}

class CheckoutSumItem extends StatelessWidget {
  final int total;
  final String currency;

  const CheckoutSumItem({Key? key, required this.total, required this.currency}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Total'),
      trailing: Text(StripeUiOptions.formatCurrency(context, currency, total)),
    );
  }
}

class CheckoutItem extends StatelessWidget {
  final String name;
  final int price;
  final String currency;
  final int count;

  const CheckoutItem({Key? key, required this.name, required this.price, required this.currency, this.count = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      title: Text(name),
      subtitle: Text('x $count'),
      trailing: Text(StripeUiOptions.formatCurrency(context, currency, price)),
    );
  }
}
