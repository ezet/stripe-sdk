import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../stripe.dart';
import '../../ui/stores/payment_method_store.dart';
import '../progress_bar.dart';
import '../stripe_ui.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatelessWidget {
  final String title;
  final CreateSetupIntent createSetupIntent;

  /// The payment method store to use.
  final PaymentMethodStore _paymentMethodStore;

  static Route<void> route(
      {required CreateSetupIntent createSetupIntent, String title = '', PaymentMethodStore? paymentMethodStore}) {
    return MaterialPageRoute(
        builder: (context) => PaymentMethodsScreen(
              createSetupIntent: createSetupIntent,
              title: title,
              paymentMethodStore: paymentMethodStore,
            ));
  }

  PaymentMethodsScreen(
      {Key? key,
      required this.createSetupIntent,
      this.title = 'Payment Methods',
      PaymentMethodStore? paymentMethodStore})
      : _paymentMethodStore = paymentMethodStore ?? PaymentMethodStore(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final stripe = Stripe.instance;
    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: false,
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddPaymentMethodScreen(stripe: stripe, paymentMethodStore: _paymentMethodStore)));
              // if (added == true) await _paymentMethodStore.refresh();
            },
          )
        ],
      ),
      body: PaymentMethodsList(
        paymentMethodStore: _paymentMethodStore,
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String last4;
  final String brand;
  final DateTime expirationDate;

  const PaymentMethod(this.id, this.last4, this.brand, this.expirationDate);

  String getExpirationAsString() {
    return '${expirationDate.month}/${expirationDate.year}';
  }
}

class PaymentMethodsList extends StatefulWidget {
  final PaymentMethodStore paymentMethodStore;

  const PaymentMethodsList({Key? key, required this.paymentMethodStore}) : super(key: key);

  @override
  _PaymentMethodsListState createState() => _PaymentMethodsListState();
}

class _PaymentMethodsListState extends State<PaymentMethodsList> {
  List<PaymentMethod> paymentMethods = [];

  @override
  void initState() {
    super.initState();
    widget.paymentMethodStore.addListener(_paymentMethodStoreListener);
  }

  @override
  void dispose() {
    widget.paymentMethodStore.removeListener(_paymentMethodStoreListener);
    super.dispose();
  }

  void _paymentMethodStoreListener() {
    if (mounted) {
      setState(() => paymentMethods = widget.paymentMethodStore.paymentMethods);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await widget.paymentMethodStore.refresh(),
      child: buildListView(paymentMethods, widget.paymentMethodStore, context),
    );
  }

  Widget buildListView(List<PaymentMethod> listData, PaymentMethodStore paymentMethods, BuildContext rootContext) {
    if (paymentMethods.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
          itemCount: listData.length,
          itemBuilder: (BuildContext context, int index) {
            final card = listData[index];
            return Slidable(
              actionPane: const SlidableDrawerActionPane(),
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
                            title: const Text('Delete payment method'),
                            content: const Text('Are you sure you want to delete this payment method?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(rootContext),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(rootContext);
                                  showProgressDialog(rootContext);

                                  await widget.paymentMethodStore.detachPaymentMethod(card.id);
                                  hideProgressDialog(rootContext);
                                  await paymentMethods.refresh();
                                  ScaffoldMessenger.of(rootContext)
                                    ..clearSnackBars()
                                    ..showSnackBar(const SnackBar(
                                      content: Text('Payment method successfully deleted.'),
                                    ));
                                },
                                child: const Text('Delete'),
                              ),
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
                  leading: const Icon(Icons.credit_card),
//              trailing: card.id == defaultPaymentMethod.paymentMethodId ? Icon(Icons.check_circle) : null,
                ),
              ),
            );
          });
    }
  }
}
