

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../stripe.dart';
import '../../ui/stores/payment_method_store.dart';
import '../progress_bar.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final String title;
  final CreateSetupIntent createSetupIntent;

  /// The payment method store to use.
  final PaymentMethodStore _paymentMethodStore;

  PaymentMethodsScreen(
      {Key? key,
      required this.createSetupIntent,
      this.title = 'Payment Methods',
      PaymentMethodStore? paymentMethodStore})
      : _paymentMethodStore = paymentMethodStore ?? PaymentMethodStore(),
        super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

// ignore: deprecated_member_use_from_same_package
class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod>? paymentMethods; // TODO not used -> remove?

  @override
  Widget build(BuildContext context) {
    final stripe = Stripe.instance;

    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: false,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddPaymentMethodScreen.withSetupIntent(widget.createSetupIntent, stripe: stripe)));
              if (added == true) await widget._paymentMethodStore.refresh();
            },
          )
        ],
      ),
      body: PaymentMethodsList(
        paymentMethodStore: widget._paymentMethodStore,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget._paymentMethodStore.addListener(_paymentMethodStoreListener);
  }

  @override
  void dispose() {
    widget._paymentMethodStore.removeListener(_paymentMethodStoreListener);
    super.dispose();
  }

  void _paymentMethodStoreListener() {
    if (mounted) {
      setState(() => paymentMethods = widget._paymentMethodStore.paymentMethods);
    }
  }
}

class PaymentMethod {
  final String id;
  final String last4;
  final String brand;

  PaymentMethod(this.id, this.last4, this.brand);
}

class PaymentMethodsList extends StatelessWidget {
  final PaymentMethodStore paymentMethodStore;

  const PaymentMethodsList({Key? key, required this.paymentMethodStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<PaymentMethod> listData = paymentMethodStore.paymentMethods;
    return RefreshIndicator(
      onRefresh: () => paymentMethodStore.refresh(),
      child: buildListView(listData, paymentMethodStore, context),
    );
  }

  Widget buildListView(List<PaymentMethod> listData, PaymentMethodStore paymentMethods, BuildContext rootContext) {
    if (listData.isEmpty) {
      // TODO: loading indicator
      return SizedBox();
    } else {
      return ListView.builder(
          itemCount: listData.length,
          itemBuilder: (BuildContext context, int index) {
            final card = listData[index];
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actions: <Widget>[
//                IconSlideAction(
//                  icon: Icons.edit,
//                  color: Theme.of(context).accentColor  ,
////                  color: Colors.green,
//                  caption: "Edit",
//                ),
                IconSlideAction(
                  caption: 'Delete',
                  icon: Icons.delete_forever,
//                  color: Theme.of(context).errorColor,
                  color: Colors.red,
//                  closeOnTap: true,
                  onTap: () async {
                    await showDialog(
                        context: rootContext,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete payment method'),
                            content: Text('Are you sure you want to delete this payment method?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(rootContext),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(rootContext);
                                  showProgressDialog(rootContext);

                                  await paymentMethodStore.detachPaymentMethod(card.id);
                                  hideProgressDialog(rootContext);
                                  await paymentMethods.refresh();
                                  ScaffoldMessenger.of(rootContext).showSnackBar(SnackBar(
                                    content: Text('Payment method successfully deleted.'),
                                  ));
                                },
                                child: Text('Delete'),),
                            ],
                          );
                        });
                  },
                )
              ],
              child: Card(
                child: ListTile(
                  onLongPress: () async {},
//              onTap: () => defaultPaymentMethod.set(card.id),
                  subtitle: Text('**** **** **** ${card.last4}'),
                  title: Text(card.brand.toUpperCase()),
                  leading: Icon(Icons.credit_card),
//              trailing: card.id == defaultPaymentMethod.paymentMethodId ? Icon(Icons.check_circle) : null,
                ),
              ),
            );
          });
    }
  }
}
