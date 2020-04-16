import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../stripe.dart';
import 'models.dart';

@Deprecated("experimental")
class CheckoutScreen extends StatelessWidget {
  final Iterable<CheckoutItem> items;
  final Iterable<PaymentMethod> paymentMethods;
  final String title;
  final Future<IntentResponse> Function(int amount) createPaymentIntent;

  const CheckoutScreen(
      {Key key,
      @required this.title,
      @required this.items,
      @required this.paymentMethods,
      @required this.createPaymentIntent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int total = items.fold(0, (value, item) => value + item.price * item.count);
    final intentResponseFuture = createPaymentIntent(total);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(child: CheckoutItemList(items: items, total: total)),
          SizedBox(
            height: 40,
          ),
          Center(
            child: PaymentMethodSelector(
                paymentMethods: paymentMethods, selectedPaymentMethod: null, onChanged: (value) => debugPrint(value)),
          ),
          Center(
            child: RaisedButton(
              onPressed: () async {
                final intentResponse = await intentResponseFuture;
                return Stripe.instance.confirmPayment(intentResponse.clientSecret);
              },
              child: Text('Pay ${(total / 100).toStringAsFixed(2)}'),
            ),
          )
        ],
      ),
    );
  }
}

@Deprecated("experimental")
class CheckoutItemList extends StatelessWidget {
  final List<CheckoutItem> items;
  final int total;

  const CheckoutItemList({Key key, @required this.items, @required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = List<Widget>.from(items);
    list.add(CheckoutSumItem(total: total));
    return ListView(
      children: list,
      shrinkWrap: true,
    );
  }
}

class CheckoutSumItem extends StatelessWidget {
  final int total;

  const CheckoutSumItem({Key key, @required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Total"),
      trailing: Text((total / 100).toStringAsFixed(2)),
    );
  }
}

class CheckoutItem extends StatelessWidget {
  final String name;
  final int price;
  final String currency;
  final int count;

  const CheckoutItem({Key key, @required this.name, @required this.price, @required this.currency, this.count = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      title: Text(name),
      subtitle: Text("x $count"),
      trailing: Text((price / 100).toStringAsFixed(2)),
    );
  }
}

class PaymentMethod {
  final String id;
  final String last4;

  PaymentMethod(this.id, this.last4);
}

class PaymentMethodSelector extends StatelessWidget {
  PaymentMethodSelector(
      {Key key, @required this.paymentMethods, @required this.selectedPaymentMethod, @required this.onChanged})
      : super(key: key);

  final String selectedPaymentMethod;
  final void Function(String) onChanged;
  final Iterable<PaymentMethod> paymentMethods;

  @override
  Widget build(BuildContext context) {
    final method = paymentMethods?.singleWhere((item) => item.id == selectedPaymentMethod, orElse: () => null);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: DropdownButton(
        underline: null,
        isExpanded: true,
        value: method?.id,
        items: paymentMethods
            ?.map((item) => DropdownMenuItem(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("**** **** **** ${item.last4}"),
                  ),
                  value: item.id,
                ))
            ?.toList(),
        onChanged: (value) => onChanged(value),
      ),
    );
  }
}
