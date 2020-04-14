import 'package:app/ui/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import 'locator.dart';
import 'network/network_service.dart';

class PaymentMethodsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PaymentMethodsData paymentMethods = Provider.of(context);
    final Stripe stripe = locator.get();
    final NetworkService networkService = locator.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment methods"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          // ignore: deprecated_member_use
                          AddPaymentMethod.withSetupIntent(networkService.createSetupIntent, stripe: stripe)));
              if (added == true) await paymentMethods.refresh();
            },
          )
        ],
      ),
      body: PaymentMethodsList(),
    );
  }
}

class PaymentMethod {
  final String id;
  final String last4;
  final String brand;

  PaymentMethod(this.id, this.last4, this.brand);
}

class PaymentMethodsData extends ChangeNotifier {
  List<PaymentMethod> paymentMethods = List();
  Future<List<PaymentMethod>> paymentMethodsFuture;

  PaymentMethodsData() {
    refresh();
  }

  Future<void> refresh() {
    final session = locator.get<CustomerSession>();
    final paymentMethodFuture = session.listPaymentMethods();

    return paymentMethodFuture.then((value) {
      final List listData = value['data'] ?? List<PaymentMethod>();
      if (listData.isEmpty) {
        paymentMethods = List();
      } else {
        paymentMethods =
            listData.map((item) => PaymentMethod(item['id'], item['card']['last4'], item['card']['brand'])).toList();
      }
      notifyListeners();
    });
  }
}

class PaymentMethodsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final paymentMethods = Provider.of<PaymentMethodsData>(context);
    final listData = paymentMethods.paymentMethods;
//    final defaultPaymentMethod = Provider.of<DefaultPaymentMethod>(context);
    if (listData == null) {
      return Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => paymentMethods.refresh(),
      child: buildListView(listData, paymentMethods, context),
    );
  }

  Widget buildListView(List<PaymentMethod> listData, PaymentMethodsData paymentMethods, BuildContext rootContext) {
    final stripeSession = locator.get<CustomerSession>();
    if (listData.isEmpty) {
      return ListView();
    } else {
      return ListView.builder(
          itemCount: listData.length,
          itemBuilder: (BuildContext context, int index) {
            final card = listData[index];
            return ListTile(
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
            );
          });
    }
  }
}
