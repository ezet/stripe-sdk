import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/ui/stripe_web_view.dart';
import "package:universal_html/html.dart" as html;
import 'package:url_launcher/url_launcher.dart';

import 'stripe_api.dart';
import 'ui/stripe_ui.dart';

class Stripe {
  /// Creates a new [Stripe] object. Use this constructor if you wish to handle the instance of this class by yourself.
  /// Alternatively, use [Stripe.init] to create a singleton and access it through [Stripe.instance].
  ///
  /// [publishableKey] is your publishable key, beginning with "pk_".
  /// Your can copy your key from https://dashboard.stripe.com/account/apikeys
  ///
  /// [stripeAccount] is the id of a stripe customer and stats with "cus_".
  /// This is a optional parameter.
  ///
  /// [returnUrlForSca] should be used to specify a unique return url for
  /// Strong Customer Authentication (SCA) such as 3DS, 3DS2, BankID and others.
  /// It is required to use your own app specific url scheme and host. This
  /// parameter must match your "android/app/src/main/AndroidManifest.xml"
  /// and "ios/Runner/Info.plist" configuration.
  Stripe(String publishableKey, {String? stripeAccount})
      : api = StripeApi(publishableKey, stripeAccount: stripeAccount);

  final StripeApi api;
  static Stripe? _instance;

  /// Access the instance of Stripe by calling [Stripe.instance].
  /// Throws an [Exception] if [Stripe.init] hasn't been called previously.
  static Stripe get instance {
    if (_instance == null) {
      throw Exception('Attempted to get singleton instance of Stripe without initialization');
    }
    return _instance!;
  }

  /// Initializes the singleton instance of [Stripe]. Afterwards you can
  /// use [Stripe.instance] to access the created instance.
  ///
  /// [publishableKey] is your publishable key, beginning with "pk_".
  /// Your can copy your key from https://dashboard.stripe.com/account/apikeys
  ///
  /// [stripeAccount] is the id of a stripe customer and stats with "cus_".
  /// This is a optional parameter.
  ///
  /// [returnUrlForSca] should be used to specify a unique return url for
  /// Strong Customer Authentication (SCA) such as 3DS, 3DS2, BankID and others.
  /// It is required to use your own app specific url scheme and host. This
  /// parameter must match your "android/app/src/main/AndroidManifest.xml"
  /// and "ios/Runner/Info.plist" configuration.
  static void init(String publishableKey, {String? stripeAccount}) {
    _instance = Stripe(publishableKey, stripeAccount: stripeAccount);
    StripeApi.init(publishableKey, stripeAccount: stripeAccount);
  }

  /// Creates a return URL that can be used to authenticate a single PaymentIntent.
  /// This should be set on the intent before attempting to authenticate it.
  String getReturnUrlForSca({String? webReturnUrl}) {
    if (kIsWeb) {
      return webReturnUrl ?? StripeUiOptions.defaultWebReturnUrl;
    } else {
      final requestId = Random.secure().nextInt(99999999);
      return '${StripeUiOptions.defaultMobileReturnUrl}?requestId=$requestId';
    }
  }

  /// Authenticate a SetupIntent
  /// https://stripe.com/docs/api/setup_intents/confirm
  Future<Map<String, dynamic>> authenticateSetupIntent(String clientSecret,
      {String? webReturnPath, required BuildContext context}) async {
    final Map<String, dynamic> intent = await api.confirmSetupIntent(
      clientSecret,
      data: {'return_url': getReturnUrlForSca(webReturnUrl: webReturnPath)},
    );
    return _handleSetupIntent(intent, context);
  }

  /// Confirm and authenticate a SetupIntent
  /// https://stripe.com/docs/api/setup_intents/confirm
  Future<Map<String, dynamic>> confirmSetupIntent(String clientSecret, String paymentMethod,
      {String? webReturnPath, required BuildContext context}) async {
    var returnUrlForSca = getReturnUrlForSca(webReturnUrl: webReturnPath);
    final Map<String, dynamic> intent = await api.confirmSetupIntent(
      clientSecret,
      data: {
        'return_url': returnUrlForSca,
        'payment_method': paymentMethod,
      },
    );
    return _handleSetupIntent(intent, context);
  }

  /// Confirm and authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android
  Future<Map<String, dynamic>> confirmPayment(String paymentIntentClientSecret, BuildContext context,
      {String? paymentMethodId}) async {
    final data = {'return_url': getReturnUrlForSca()};
    if (paymentMethodId != null) data['payment_method'] = paymentMethodId;
    final Map<String, dynamic> paymentIntent = await api.confirmPaymentIntent(
      paymentIntentClientSecret,
      data: data,
    );
    return _handlePaymentIntent(paymentIntent, context);
  }

  /// Authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android-manual
  Future<Map<String, dynamic>> authenticatePayment(String paymentIntentClientSecret, BuildContext context) async {
    final Map<String, dynamic> paymentIntent = await api.retrievePaymentIntent(paymentIntentClientSecret);
    return _handlePaymentIntent(paymentIntent, context);
  }

  /// Authenticate a payment with [paymentIntent].
  /// This is similar to [authenticatePayment] but is slightly more efficient,
  /// as it avoids the request to the Stripe API to retrieve the action.
  /// To use this, return the complete [paymentIntent] from your server.
  Future<Map<String, dynamic>> _handlePaymentIntent(Map<String, dynamic> paymentIntent, BuildContext context) async {
    return _authenticateIntent(paymentIntent, context, api.retrievePaymentIntent);
  }

  /// Launch 3DS in a new browser window.
  /// Returns a [Future] with the Stripe SetupIntent when the user completes or cancels authentication.
  Future<Map<String, dynamic>> _handleSetupIntent(Map<String, dynamic> setupIntent, BuildContext context) async {
    return _authenticateIntent(setupIntent, context, api.retrieveSetupIntent);
  }

  Future<Map<String, dynamic>> _authenticateIntent(Map<String, dynamic> intent, BuildContext context,
      Future<Map<String, dynamic>> Function(String clientSecret) getIntentFunction) async {
    if (intent['status'] != 'requires_action') return intent;
    final clientSecret = intent['client_secret'];
    final action = intent['next_action'];
    final String url = action['redirect_to_url']['url'];
    final returnUri = Uri.parse(action['redirect_to_url']['return_url']);

    if (kIsWeb) {
      return _authenticateWithBrowser(context, url, returnUri, getIntentFunction, clientSecret);
    } else {
      await _authenticateWithWebView(context, url, returnUri);
      return getIntentFunction(clientSecret);
    }
  }

  Future<Map<String, dynamic>> _authenticateWithBrowser(BuildContext context, String url, Uri returnUri,
      Future<Map<String, dynamic>> Function(String clientSecret) getIntentFunction, String clientSecret) async {
    final completer = Completer<Map<String, dynamic>>();

    late StreamSubscription<html.Event> subscription;
    subscription = html.window.onFocus.listen((event) async {
      final intent = await getIntentFunction(clientSecret);
      if (intent['status'] != 'requires_action') {
        Navigator.of(context).pop();
        subscription.cancel();
        await Future.delayed(const Duration(seconds: 1));
        completer.complete(intent);
        return;
      }
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: const Text("Awaiting authentication, please complete authentication in the opened window."),
        children: [
          SimpleDialogOption(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
              subscription.cancel();
              completer.complete(getIntentFunction(clientSecret));
            },
          ),
          SimpleDialogOption(
            child: const Text("Open new window"),
            onPressed: () {
              Navigator.of(context).pop();
              launch(url, enableJavaScript: true);
            },
          )
        ],
      ),
    );

    await launch(url, enableJavaScript: true);

    return completer.future;
  }

  Future<bool?> _authenticateWithWebView(BuildContext context, String url, Uri returnUri) async {
    return Navigator.push<bool?>(
        context,
        MaterialPageRoute(
          builder: (context) => StripeWebView(
            uri: url,
            returnUri: returnUri,
          ),
        ));
  }
}
