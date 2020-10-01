import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stripe_sdk/src/ui-flow/model/payment_method_models.dart';
import 'package:stripe_sdk/src/ui-flow/service/payment_methods_notifier.dart';
import '../../../stripe_sdk_ui.dart';
import 'add_payment_method.dart';
import 'add_shipping.dart';

typedef CheckoutBuilder = Widget Function(
    BuildContext context,
    AttachShippingToPaymentModel shippingDetail,
    PaymentMethodModel paymentMethod);

class PaymentMethods extends StatefulWidget {
  //These three properties bellow will provide moderate customization if you want to change the payment method's screen color, evelation, or/and background color.

  ///change app bar title
  final Widget appBarTitle;

  ///add your own customized card form
  final CardForm cardForm;

  ///change app bar elevation
  final double appBarElevation;

  ///change app bar background
  final Color appBarBackgroundColor;

  ///Note that if you set [withShippingDetail] to false, your user will not be directed to the shipping fillout page, which means [shippingDetail] in [CheckoutBuilder] will be null.
  final bool withShippingPage;
  final CheckoutBuilder checkoutBuilder;

  // ignore: deprecated_member_use
  final SetupIntent setupIntent;

  PaymentMethods({
    Key key,
    @required this.setupIntent,
    this.appBarTitle = const Text('Payment Methods'),
    this.appBarElevation,
    this.appBarBackgroundColor,
    this.cardForm,
    PaymentMethodsNotifier paymentMethodsNotifier,
    //By default set to ask the user shipping address entry, you can override this when invoking the object
    this.withShippingPage = true,
    @required this.checkoutBuilder,
  })  : assert(checkoutBuilder != null),
        super(key: key);

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

// ignore: deprecated_member_use_from_same_package
class _PaymentMethodsState extends State<PaymentMethods> {
  // ignore: deprecated_member_use_from_same_package
  Future<PaymentMethodsListModel> _paymentMethods;
  PaymentMethodModel _paymentMethod;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    PaymentMethodsNotifier.instance.addListener(_paymentMethodStoreListener);
    _paymentMethods = PaymentMethodsNotifier.instance.getPaymentMethods();
  }

  @override
  void dispose() {
    super.dispose();
    PaymentMethodsNotifier.instance.removeListener(_paymentMethodStoreListener);
  }

  Future<void> _paymentMethodStoreListener() async {
    if (mounted) {
      var data = PaymentMethodsNotifier.instance.getPaymentMethods();
      setState(() {
        _paymentMethods = data;
      });
    }
  }

  //Route to checkout
  void _navigateToCheckout(PaymentMethodModel paymentMethod) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            widget.checkoutBuilder(context, null, paymentMethod),
      ),
    );
  }

  //Route to shipping
  void _navigateToShipping(PaymentMethodModel paymentMethod) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttachShippingToPayment(
          paymentMethod,
          checkoutBuilder: widget.checkoutBuilder,
          appBarElevation: widget.appBarElevation,
          appBarBackgroundColor: widget.appBarBackgroundColor,
        ),
      ),
    );
  }

  //android
  Widget _android() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: widget.appBarTitle,
        elevation: widget.appBarElevation,
        backgroundColor: widget.appBarBackgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (widget.withShippingPage == true) {
                //Go to shipping address entry page
                if (_paymentMethod == null) {
                  final defPayment = await PaymentMethodsNotifier
                      .instance.deafultPaymentMethod;
                  _navigateToShipping(defPayment);
                } else {
                  _navigateToShipping(_paymentMethod);
                }
              } else {
                //Go to check out page
                if (_paymentMethod == null) {
                  final defPayment = await PaymentMethodsNotifier
                      .instance.deafultPaymentMethod;
                  _navigateToCheckout(defPayment);
                } else {
                  _navigateToCheckout(_paymentMethod);
                }
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: FutureBuilder<PaymentMethodsListModel>(
              future: _paymentMethods,
              builder: (BuildContext context,
                  AsyncSnapshot<PaymentMethodsListModel> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: CircularProgressIndicator(
                          backgroundColor: widget.appBarBackgroundColor,
                        ));
                    break;
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      throw snapshot.error;
                    }
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final defaultPaymentMethod = snapshot.data.data[0];
                          return PaymentMethodCard(
                            scaffoldKey: _scaffoldKey,
                            paymentMethod: snapshot.data.data[index],
                            paymentMethodCallBack: (paymentMethod) {
                              assert(paymentMethod != null);
                              setState(() {
                                _paymentMethod = paymentMethod;
                              });
                            },
                            paymentMethodId: _paymentMethod?.paymentMethodId ??
                                defaultPaymentMethod?.paymentMethodId,
                          );
                        },
                      );
                    }
                    break;
                }
                return Container(width: 0.0, height: 0.0);
              },
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      // ignore: deprecated_member_use
                      AddPaymentMethod.withSetupIntent(
                    widget.setupIntent,
                    form: widget.cardForm,
                    appBarElevation: widget.appBarElevation,
                    appBarBackgroundColor: widget.appBarBackgroundColor,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  size: 33,
                  color: Colors.blue,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Add new card...',
                    style: TextStyle(
                        fontSize: 19.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  ////iphone
  // Widget _iphone() {
  //   return SafeArea(
  //     child: CupertinoPageScaffold(
  //       navigationBar: CupertinoNavigationBar(
  //         leading: Material(
  //           child: FlatButton(
  //             padding: const EdgeInsets.only(right: 30.0),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: CupertinoColors.activeBlue,
  //               ),
  //             ),
  //           ),
  //         ),
  //         middle: Text(
  //           'Payment Method',
  //           style: TextStyle(fontSize: 15.0),
  //         ),
  //         trailing: Material(
  //           child: FlatButton(
  //             padding: const EdgeInsets.only(left: 30.0),
  //             onPressed: () {},
  //             child: Text(
  //               'Edit',
  //               style: TextStyle(
  //                 color: CupertinoColors.activeBlue,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       child: Material(
  //         child: Text('Comming soon'),
  //       ),
  //     ),
  //   );
  // }

  Widget _app() {
    // if (Platform.isIOS) {
    //   return null;
    // }
    return _android();
  }

  @override
  Widget build(BuildContext context) {
    return _app();
  }
}

//Payment Method Card ////////////////////////////////////////////////////////////////////////////////////////
class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel paymentMethod;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final void Function(PaymentMethodModel paymentMethod) paymentMethodCallBack;
  final String paymentMethodId;

  const PaymentMethodCard(
      {Key key,
      this.paymentMethod,
      this.paymentMethodCallBack,
      this.paymentMethodId,
      this.scaffoldKey})
      : super(key: key);

  Widget _android(BuildContext context) {
    return InkWell(
      onTap: () {
        //Callback function
        paymentMethodCallBack(paymentMethod);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 16.0,
                    ),
                    child: Image.asset(
                        'assets/images/${paymentMethod.cardModel.cardImage}',
                        color: paymentMethodId == paymentMethod.paymentMethodId
                            ? Colors.blue
                            : const Color.fromARGB(255, 92, 100, 128),
                        width: 33.0,
                        package: 'stripe_sdk'),
                  ),
                  RichText(
                    text: TextSpan(
                      text: '',
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: paymentMethod.cardModel.capitalizedBrand,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19.0,
                              color: paymentMethodId ==
                                      paymentMethod.paymentMethodId
                                  ? Colors.blue
                                  : const Color.fromARGB(255, 92, 100, 128)),
                        ),
                        TextSpan(
                          text: ' ending in ',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17.5,
                              letterSpacing: 0.2,
                              color: paymentMethodId ==
                                      paymentMethod.paymentMethodId
                                  ? Colors.blue
                                  : const Color.fromARGB(255, 92, 100, 128)),
                        ),
                        TextSpan(
                          text: paymentMethod.cardModel.last4,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            color:
                                paymentMethodId == paymentMethod.paymentMethodId
                                    ? Colors.blue
                                    : const Color.fromARGB(255, 92, 100, 128),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            paymentMethodId == paymentMethod.paymentMethodId
                ? Icon(Icons.check, size: 24.0, color: Colors.blue)
                : Container(
                    width: 0.0,
                    height: 0.0,
                  )
          ],
        ),
      ),
    );
  }

  Widget _app(BuildContext context) {
    if (Platform.isIOS) {
      return null;
    }
    return _android(context);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actions: <Widget>[
        IconSlideAction(
          //caption: 'Delete',
          icon: Icons.delete_forever,
          color: Colors.red,
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 26.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Delete Card',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        )
                      ],
                    ),
                    content: DefaultTextStyle(
                      style: Theme.of(context).textTheme.headline6,
                      child: RichText(
                        text: TextSpan(
                          text: '',
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Are you sure you want to delete ',
                              style: TextStyle(
                                  //fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 19.0,
                                  height: 1.4),
                            ),
                            TextSpan(
                              text:
                                  '${paymentMethod.cardModel.brand.toUpperCase()}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 19.0,
                                  height: 1.4),
                            ),
                            TextSpan(
                              text: ' card ending in ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  height: 1.4),
                            ),
                            TextSpan(
                              text: '${paymentMethod.cardModel.last4}?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  height: 1.4),
                            )
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FlatButton(
                          child: Text(
                            'Delete',
                            style: TextStyle(fontSize: 18.0, color: Colors.red),
                          ),
                          onPressed: () {
                            PaymentMethodsNotifier.instance
                                .detachPaymentMethod(
                                    paymentMethod.paymentMethodId)
                                .then((value) {
                              if (value != null) {

                                var snackbar = SnackBar(
                                    content:
                                        Text('Card successfully deleted!'));
                                scaffoldKey?.currentState
                                    ?.showSnackBar(snackbar);
                                Navigator.pop(context);
                              } else {
                                var snackbar = SnackBar(
                                    content: Text(
                                        'Failed to delete card! Check your connectioin and try again'));
                                scaffoldKey?.currentState
                                    ?.showSnackBar(snackbar);

                                Navigator.pop(context);
                              }
                            });
                          }),
                    ],
                  );
                });
          },
        )
      ],
      child: _app(context),
    );
  }
}
