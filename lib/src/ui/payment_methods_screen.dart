import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import 'progress_bar.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final String title;
  final CreateSetupIntent createSetupIntent;
  final PaymentMethodStore paymentMethodStore;

  PaymentMethodsScreen(
      {Key key,
      @required this.createSetupIntent,
      this.title = "Payment Methods",
      PaymentMethodStore paymentMethodsData})
      : this.paymentMethodStore = paymentMethodsData ?? PaymentMethodStore(),
        super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> paymentMethods;

  @override
  Widget build(BuildContext context) {
    final Stripe stripe = Stripe.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          // ignore: deprecated_member_use_from_same_package
                          AddPaymentMethodScreen.withSetupIntent(widget.createSetupIntent, stripe: stripe)));
              if (added == true) await widget.paymentMethodStore.refresh();
            },
          )
        ],
      ),
      body: PaymentMethodsList(
        paymentMethodStore: widget.paymentMethodStore,
      ),
    );
  }

  @override
  void initState() {
    widget.paymentMethodStore.addListener(() => setState(() => this.paymentMethods = widget.paymentMethodStore.paymentMethods));
  }
}

class PaymentMethod {
  final String id;
  final String last4;
  final String brand;

  PaymentMethod(this.id, this.last4, this.brand);
}

class PaymentMethodStore extends ChangeNotifier {
  final List<PaymentMethod> paymentMethods = List();

  PaymentMethodStore() {
    refresh();
  }

  Future<void> refresh() {
    final session = CustomerSession.instance;
    final paymentMethodFuture = session.listPaymentMethods();

    return paymentMethodFuture.then((value) {
      final List listData = value['data'] ?? List<PaymentMethod>();
      paymentMethods.clear;
      if (listData.isNotEmpty) {
        paymentMethods.addAll(
            listData.map((item) => PaymentMethod(item['id'], item['card']['last4'], item['card']['brand'])).toList());
      }
      notifyListeners();
    });
  }
}

class PaymentMethodsList extends StatelessWidget {
  final PaymentMethodStore paymentMethodStore;

  const PaymentMethodsList({Key key, @required this.paymentMethodStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listData = paymentMethodStore.paymentMethods;
//    final defaultPaymentMethod = Provider.of<DefaultPaymentMethod>(context);
    if (listData == null) {
      return Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => paymentMethodStore.refresh(),
      child: buildListView(listData, paymentMethodStore, context),
    );
  }

  Widget buildListView(List<PaymentMethod> listData, PaymentMethodStore paymentMethods, BuildContext rootContext) {
    final stripeSession = CustomerSession.instance;
    if (listData.isEmpty) {
      // TODO: loading indicator
      return ListView();
    } else {
      return ListView.builder(
          itemCount: listData.length,
          itemBuilder: (BuildContext context, int index) {
            final card = listData[index];
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              child: Card(
                child: ListTile(
                  onLongPress: () async {
                    await showDialog(
                        context: rootContext,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete card"),
                            content: Text("Do you want to delete this card?"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("No"),
                                onPressed: () => Navigator.pop(rootContext),
                              ),
                              FlatButton(
                                  child: Text("Yes"),
                                  onPressed: () async {
                                    Navigator.pop(rootContext);
                                    showProgressDialog(rootContext);

                                    final result = await stripeSession.detachPaymentMethod(card.id);
                                    hideProgressDialog(rootContext);
                                    if (result != null) {
                                      await paymentMethods.refresh();
                                      Scaffold.of(rootContext).showSnackBar(SnackBar(
                                        content: Text('Payment method successfully deleted.'),
                                      ));
                                    }
                                  })
                            ],
                          );
                        });
                  },
//              onTap: () => defaultPaymentMethod.set(card.id),
                  subtitle: Text(card.last4),
                  title: Text(card.brand),
                  leading: Icon(Icons.credit_card),
//              trailing: card.id == defaultPaymentMethod.paymentMethodId ? Icon(Icons.check_circle) : null,
                ),
              ),
            );
          });
    }
  }
}
