import 'dart:async';
import 'dart:math';

import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'stripe_api.dart';

class Stripe {
  Stripe(String publishableKey, {String stripeAccount})
      : _stripeApi = StripeApi(publishableKey, stripeAccount: stripeAccount);

  final StripeApi _stripeApi;
  static Stripe _instance;

  static Stripe get instance {
    if (_instance == null) {
      throw Exception(
          "Attempted to get singleton instance of Stripe without initialization");
    }
    return _instance;
  }

  static void init(String publishableKey, String stripeAccount) {
    _instance = Stripe(publishableKey, stripeAccount: stripeAccount);
  }

  /// Creates a return URL that can be used to authenticate a single PaymentIntent.
  /// This should be set on the intent before attempting to authenticate it.
  static String getReturnUrl() {
    final requestId = Random.secure().nextInt(99999999);
    return "stripesdk://3ds.stripesdk.io?requestId=$requestId";
  }

  /// Confirm a SetupIntent
  /// https://stripe.com/docs/api/setup_intents/confirm
  Future<Map<String, dynamic>> confirmSetupIntent(String clientSecret) async {
    final intent = await _stripeApi
        .confirmSetupIntent(clientSecret, data: {'return_url': getReturnUrl()});
    if (intent['status'] == 'requires_action') {
      return handleSetupIntent(intent['next_action']);
    } else {
      return Future.value(intent);
    }
  }

  /// Confirm a SetupIntent with a PaymentMethod
  /// https://stripe.com/docs/api/setup_intents/confirm
  Future<Map<String, dynamic>> confirmSetupIntentWithPaymentMethod(
      String clientSecret, String paymentMethod) async {
    final intent = await _stripeApi.confirmSetupIntent(clientSecret,
        data: {'return_url': getReturnUrl(), 'payment_method': paymentMethod});
    if (intent['status'] == 'requires_action') {
      return handleSetupIntent(intent['next_action']);
    } else {
      return Future.value(intent);
    }
  }

  /// Confirm and authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android
  Future<Map<String, dynamic>> confirmPayment(
      String paymentIntentClientSecret, String paymentMethodId) async {
    final paymentIntent = await _stripeApi
        .confirmPaymentIntent(paymentIntentClientSecret, data: {
      'return_url': getReturnUrl(),
      'payment_method': paymentMethodId
    });
    if (paymentIntent['status'] == "requires_action") {
      return handlePaymentIntent(paymentIntent['next_action']);
    } else {
      return Future.value(paymentIntent);
    }
  }

  /// Authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android-manual
  Future<Map<String, dynamic>> authenticatePayment(
      String paymentIntentClientSecret) async {
    final paymentIntent = await StripeApi.instance
        .retrievePaymentIntent(paymentIntentClientSecret);
    if (paymentIntent['status'] == "requires_action") {
      return handlePaymentIntent(paymentIntent['next_action']);
    } else {
      return Future.value(paymentIntent);
    }
  }

  /// Launch 3DS in a new browser window.
  /// Returns a [Future] with the Stripe PaymentIntent when the user completes or cancels authentication.
  Future<Map<String, dynamic>> handlePaymentIntent(Map action) async {
    return _authenticateIntent(
        action,
        (uri) => _stripeApi.retrievePaymentIntent(
              uri.queryParameters['payment_intent_client_secret'],
            ));
  }

  /// Launch 3DS in a new browser window.
  /// Returns a [Future] with the Stripe SetupIntent when the user completes or cancels authentication.
  Future<Map<String, dynamic>> handleSetupIntent(Map action) async {
    return _authenticateIntent(
        action,
        (uri) => _stripeApi.retrieveSetupIntent(
              uri.queryParameters['setup_intent_client_secret'],
            ));
  }

  Future<Map<String, dynamic>> _authenticateIntent(
      Map action, IntentProvider callback) async {
    final url = action['redirect_to_url']['url'];
    final returnUrl = Uri.parse(action['redirect_to_url']['return_url']);
    final completer = Completer<Map<String, dynamic>>();
    StreamSubscription sub;
    sub = getUriLinksStream().listen((Uri uri) async {
      if (uri.scheme == returnUrl.scheme &&
          uri.host == returnUrl.host &&
          uri.queryParameters['requestId'] ==
              returnUrl.queryParameters['requestId']) {
        await sub.cancel();
        final intent = await callback(uri);
        completer.complete(intent);
      }
    });

    await launch(url);
    return completer.future;
  }
}
