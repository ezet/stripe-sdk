import 'package:flutter/material.dart';

import '../../stripe.dart';
import '../../ui/stores/payment_method_store.dart';
import '../progress_bar.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatelessWidget {
  final String title;

  /// The payment method store to use.
  final PaymentMethodStore _paymentMethodStore;

  static Route<void> route({String title = '', PaymentMethodStore? paymentMethodStore}) {
    return MaterialPageRoute(
        builder: (context) => PaymentMethodsScreen(
              title: title,
              paymentMethodStore: paymentMethodStore,
            ));
  }

  PaymentMethodsScreen({Key? key, this.title = 'Payment Methods', PaymentMethodStore? paymentMethodStore})
      : _paymentMethodStore = paymentMethodStore ?? PaymentMethodStore.instance,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final stripe = Stripe.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                  context, AddPaymentMethodScreen.route(paymentMethodStore: _paymentMethodStore, stripe: stripe));
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
    widget.paymentMethodStore.addListener(paymentMethodStoreListener);
    setState(() => paymentMethods = widget.paymentMethodStore.paymentMethods);
  }

  @override
  void didUpdateWidget(PaymentMethodsList oldWidget) {
    widget.paymentMethodStore.addListener(paymentMethodStoreListener);
    widget.paymentMethodStore.removeListener(paymentMethodStoreListener);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.paymentMethodStore.removeListener(paymentMethodStoreListener);
    super.dispose();
  }

  void paymentMethodStoreListener() {
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
            return Card(
              child: ListTile(
                onLongPress: () async {},
                onTap: () => _displayDeletePaymentMethodDialog(rootContext, card, paymentMethods),
                title: Text(card.last4),
                subtitle: Text(card.brand.toUpperCase()),
                leading: const Icon(Icons.credit_card),
                // trailing: card.id == defaultPaymentMethod.paymentMethodId ? Icon(Icons.check_circle) : null,
                trailing: IconButton(
                  onPressed: () => _displayDeletePaymentMethodDialog(rootContext, card, paymentMethods),
                  icon: const Icon(Icons.cancel),
                ),
              ),
            );
          });
    }
  }

  Future<void> _displayDeletePaymentMethodDialog(
      BuildContext context, PaymentMethod card, PaymentMethodStore paymentMethods) async {
    showDialog(
        context: context,
        builder: (BuildContext alertDialogContext) {
          return AlertDialog(
            title: const Text('Delete payment method'),
            content: const Text('Are you sure you want to delete this payment method?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(alertDialogContext, rootNavigator: true).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(alertDialogContext, rootNavigator: true).pop();
                  showProgressDialog(context);
                  await widget.paymentMethodStore
                      .detachPaymentMethod(card.id)
                      .whenComplete(() => hideProgressDialog(context));
                  ScaffoldMessenger.of(context)
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
  }
}
