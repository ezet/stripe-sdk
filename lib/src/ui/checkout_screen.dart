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

@Deprecated('Experimental')
class CheckoutScreen extends StatefulWidget {
  final List<CheckoutItem> items;
  final String title;
  final Future<IntentResponse> Function(int amount) createPaymentIntent;
  final void Function(BuildContext context)? onPaymentSuccess;
  final void Function(BuildContext context, StripeApiException e)? onPaymentError;

  const CheckoutScreen(
      {Key? key,
      required this.title,
      required this.items,
      required this.createPaymentIntent,
      this.onPaymentSuccess,
      this.onPaymentError})
      : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

// ignore: deprecated_member_use_from_same_package
class _CheckoutScreenState extends State<CheckoutScreen> {
  final PaymentMethodStore paymentMethodStore = PaymentMethodStore.instance;

  String? _selectedPaymentMethod;
  late Future<IntentResponse> _paymentIntentFuture;
  late int _total;

  @override
  void initState() {
    _total = widget.items.fold(0, (int? value, CheckoutItem item) => value! + item.price * item.count);
    _paymentIntentFuture = widget.createPaymentIntent(_total);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: false,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ignore: deprecated_member_use_from_same_package
          CheckoutItemList(items: widget.items, total: _total),
          const SizedBox(
            height: 40,
          ),
          Center(
            child: PaymentMethodSelector(
                paymentMethodStore: paymentMethodStore,
                initialPaymentMethodId: null,
                onChanged: (value) => setState(() {
                      _selectedPaymentMethod = value;
                    })),
          ),
          Center(
            child: StripeUiOptions.payWidgetBuilder(context, widget.items.first.currency, _total,
                _selectedPaymentMethod == null ? null : _createAttemptPaymentFunction(context, _paymentIntentFuture)),
          )
        ],
      ),
    );
  }

  void Function() _createAttemptPaymentFunction(BuildContext context, Future<IntentResponse> paymentIntentFuture) {
    return () async {
      showProgressDialog(context);
      final paymentIntent = await paymentIntentFuture;
      try {
        final confirmationResponse = await Stripe.instance
            .confirmPayment(paymentIntent.clientSecret, context, paymentMethodId: _selectedPaymentMethod);
        hideProgressDialog(context);
        if (confirmationResponse['status'] == 'succeeded') {
          if (widget.onPaymentSuccess != null) {
            widget.onPaymentSuccess!(context);
          } else {
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              // false = user must tap button, true = tap outside dialog
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Payment successfully completed!'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('ok'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true); // Dismiss alert dialog
                      },
                    ),
                  ],
                );
              },
            );
          }
          return;
        }
      } catch (e) {
        if (widget.onPaymentError != null && e is StripeApiException) {
          widget.onPaymentError!(context, e);
        } else {
          debugPrint(e.toString());
          hideProgressDialog(context);
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
