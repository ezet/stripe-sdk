import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  const CheckoutScreen({Key? key, required this.title, required this.items, required this.createPaymentIntent})
      : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

// ignore: deprecated_member_use_from_same_package
class _CheckoutScreenState extends State<CheckoutScreen> {
  final PaymentMethodStore paymentMethodStore = PaymentMethodStore.instance;

  String? _selectedPaymentMethod;
  Future<IntentResponse>? _createIntentResponse;
  late int _total;

  @override
  void initState() {
    super.initState();
    _total = widget.items.fold(0, (int? value, CheckoutItem item) => value ?? 0 + item.price * item.count);
    _createIntentResponse = widget.createPaymentIntent(_total);
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
//            child: LoadStuffButton(),

            child: ElevatedButton(
              onPressed: () async {
                showProgressDialog(context);
                final intentResponse = await _createIntentResponse!;
                try {
                  final confirmationResponse = await Stripe.instance
                      .confirmPayment(intentResponse.clientSecret, paymentMethodId: _selectedPaymentMethod);
                  hideProgressDialog(context);
                  if (confirmationResponse['status'] == 'succeeded') {
                    await showGeneralDialog(
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionBuilder: (context, a1, a2, widget) {
                          return Transform.scale(
                            scale: a1.value,
                            child: Opacity(
                              opacity: a1.value,
                              child: AlertDialog(
                                shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                                title: const Text('Success'),
                                content: const Text('Payment successfully completed!'),
                              ),
                            ),
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 200),
                        barrierDismissible: true,
                        barrierLabel: '',
                        context: context,
                        // ignore: missing_return
                        pageBuilder: (context, animation1, animation2) {
                          return const SizedBox();
                        });
                    return;
                  }
                } catch (e) {
                  hideProgressDialog(context);
                }
              },
              child: Text('Pay ${(_total / 100).toStringAsFixed(2)}'),
            ),
          )
        ],
      ),
    );
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
    list.add(CheckoutSumItem(total: total));
    return ListView(
      shrinkWrap: true,
      children: list,
    );
  }
}

class CheckoutSumItem extends StatelessWidget {
  final int total;

  const CheckoutSumItem({Key? key, required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Total'),
      trailing: Text((total / 100).toStringAsFixed(2)),
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
      trailing: Text((price / 100).toStringAsFixed(2)),
    );
  }
}
