import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:stripe_sdk/stripe_sdk_uiflow.dart';

import 'api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    const _stripePublishableKey =
        'pk_test_51HEGllAb6Zx2vb9bHUZVkDFfUy60752LPVecpvwT5wj0tDyrNH8SyOZtXYgLGbl2pOPAAFDw40bMXXIMZKiTuSqU000yuccycJ';
    //const _returnUrl = 'stripesdk://3ds.stripesdk.io';

    //Create account for live mode for production
    //In theory, you can initialize this anywhere, once, its init, you can use its properties throughout your project and in CustomerSession class. So this needs to come before CustomerSession.
    Stripe.init(_stripePublishableKey, returnUrlForSca: null);
    //Init the customer session. In practise, this should be on the route that is ready to make a purchase or create an intent. This session is short lived because it relies on ephemeral key
    CustomerSession.initCustomerSession(
        (apiVersion) => ApiService.createEphemeralKey('2020-03-02'));
  }

  @override
  Widget build(BuildContext context) {
    final _locale = Localizations.localeOf(context);
    final _currency = NumberFormat.simpleCurrency(locale: _locale.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: RaisedButton(
            child: Text('Pay \$1.00'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  // ignore: deprecated_member_use
                  return PaymentMethods(
                    ///This will attach a shipping address with the payment intent if [true]
                    withShippingPage: false,
                    setupIntent: ApiService.createSetupIntent,
                    cardForm: CardForm(
                      cardDecoration: BoxDecoration(color: const Color.fromARGB(255,14,86,159)),
                    ),
                    checkoutBuilder: (context, shippingDetail, paymentMethod) {
                      return Scaffold(
                        body: Center(
                          child: RaisedButton(
                            onPressed: () {
                              try {
                                ApiService.createAutomaticPaymentIntent(
                                  100, //Should come from database not client for real world application
                                  paymentMethod,
                                  shippingDetail?.toJson(),
                                  _currency.currencyName.toLowerCase(),
                                ).then((value) {
                                  if (value is PaymentIntentModel) {
                                    if (value.status == 'succeeded') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShowMessage(
                                            message: value.toString(),
                                          ),
                                        ),
                                      );
                                    } else {
                                      Stripe.instance
                                          .confirmPayment(value.clientSecret,
                                              paymentMethodId:
                                                  value.paymentMethod)
                                          .then((value) {
                                        //returns payment intent object
                                        final response =
                                            PaymentIntentModel.fromJson(value);

                                        if (response.status == 'succeeded') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ShowMessage(
                                                message: response.toString(),
                                              ),
                                            ),
                                          );
                                        } else if (response.status ==
                                            'requires_payment_method') {
                                          //Failed
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ShowMessage(
                                                message: value.toString(),
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                    }
                                  } else {
                                    //Its a map and this error is due to failed charge from the server.
                                    //It has {type: 'StripeCardError',...}
                                    final error = value as Map<String, dynamic>;
                                    final errorMessage = error['message'];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowMessage(
                                          message: errorMessage,
                                        ),
                                      ),
                                    );
                                  }
                                });
                              } catch (e) {
                                //This should help us catch exceptions related to StripeApiException() from ApiService.createAutomaticPaymentIntent();
                                var message;
                                if (e is StripeApiException) {
                                  message = e.message;
                                } else {
                                  message = e.toString();
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowMessage(
                                      message: message,
                                    ),
                                  ),
                                );
                              } finally {
                                //Do finsihing stuff here related to payment regardless of exception being thrown

                              }
                            },
                            child: Text(
                                'Confirm pay'), //This widget can be anything, maybe your checkout message or whatever.
                          ),
                        ),
                      );
                    },
                    
                  );
                }),
              );
            }),
      ),
    );
  }
}

class ShowMessage extends StatelessWidget {
  final String message;

  const ShowMessage({Key key, this.message}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
            child: Text(message, style: TextStyle(fontSize: 15.0),),
          ),
        ],
      ),
    );
  }
}
