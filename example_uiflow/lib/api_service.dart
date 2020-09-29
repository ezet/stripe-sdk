import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_uiflow.dart';
import 'dart:convert';

class ApiService {
  static final String _url =
      'https://zfd.herokuapp.com'; //Simple expressjs api hosted on heroku for this example

  //Create ephemeral key for customer session
  static Future<String> createEphemeralKey(String stripeVersion) async {
    final response = await http.post(
      _url + '/ephemeral_keys',
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    } else {
      return null;
    }
  }

  //Create setup intent
  static Future<SetupIntentModel> createSetupIntent() async {
    final response = await http.post(_url + '/create_setup_intent');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var data = jsonDecode(response.body);
      return SetupIntentModel.fromJson(data);
    } else {
      return null;
    }
  }

  //Preferably you don't use the amount sent from the client and use it on server to charge, but instead, take the id of the item being sold or the id of whatever being sold, verify it on serverside, and charge the amount associated with it.

  //If you want to use Manual Payment Intent, check out Stripe.instance.authenticatePayment();
  //Here we will be using automatic payment intent which uses confirmPayment().

  static Future<Object> createAutomaticPaymentIntent(
      int amount,
      PaymentMethodModel paymentMethod,
      Map<String, dynamic> shipping,
      String currency) async {
    var data = {
      'amount': amount, //verify amount on server side
      'customer': paymentMethod
          .customer, //Verify customer on server, usually should be attached to your account object in your database
      'receipt_email': 'customer@email.com', //Same
      'payment_method': paymentMethod.paymentMethodId,
      'return_url': Stripe.instance.getReturnUrlForSca(), //Your own retrun url
      'currency': currency,
      'metadata': {
        'order_id': 2,
        'item_id': 45,
        'cus_account_id': 1 //eg: get it from current account session on client
      }
    };
    if (shipping != null) {
      data['shipping'] = shipping;
    }

    final response = await http.post(
      _url + '/pay',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var data = jsonDecode(response.body);

      if (data['type'] == 'StripeCardError') {
        final error = <String, dynamic>{};
        error['code'] = data['raw']['code'];
        error['message'] = data['raw']['message'];
        return error;
      }
      var h = PaymentIntentModel.fromJson(data);
      return h;
    } else {
      //Handle any other errors here
      return null;
    }
  }
}
