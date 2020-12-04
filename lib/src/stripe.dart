import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'stripe_api.dart';

class Stripe {
  /// Creates a new [Stripe] object. Use this constructor if you wish to handle the instance of this class by yourself.
  /// Alternatively, use [Stripe.init] to create a singleton and access it through [Stripe.instance].
  ///
  /// [publishableKey] is your publishable key, beginning with "sk_".
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
  Stripe(String publishableKey, {String stripeAccount, @required String returnUrlForSca})
      : api = StripeApi(publishableKey, stripeAccount: stripeAccount),
        _returnUrlForSca = returnUrlForSca ?? 'stripesdk://3ds.stripesdk.io' {
    // TODO: Throw real exception in 5.0
    assert(_isValidScheme());
  }

  bool _isValidScheme() {
    var isHttpScheme = ['http', 'https'].contains(_returnUrlForSca.split(':')[0]);
    if (kIsWeb) {
      assert(isHttpScheme, 'Return URL schema must be http/https when compiled for web.');
    } else {
      assert(!isHttpScheme, 'Return URL schema must not http/https when compiled for mobile.');
    }
    return true;
  }

  final StripeApi api;
  final String _returnUrlForSca;
  static Stripe _instance;

  /// Access the instance of Stripe by calling [Stripe.instance].
  /// Throws an [Exception] if [Stripe.init] hasn't been called previously.
  static Stripe get instance {
    if (_instance == null) {
      throw Exception('Attempted to get singleton instance of Stripe without initialization');
    }
    return _instance;
  }

  /// Initializes the singleton instance of [Stripe]. Afterwards you can
  /// use [Stripe.instance] to access the created instance.
  ///
  /// [publishableKey] is your publishable key, beginning with "sk_".
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
  static void init(String publishableKey, {String stripeAccount, @required String returnUrlForSca}) {
    _instance = Stripe(publishableKey, stripeAccount: stripeAccount, returnUrlForSca: returnUrlForSca);
    StripeApi.init(publishableKey, stripeAccount: stripeAccount);
  }

  /// Creates a return URL that can be used to authenticate a single PaymentIntent.
  /// This should be set on the intent before attempting to authenticate it.
  String getReturnUrlForSca({String webReturnPath}) {
    assert(kIsWeb == webReturnPath?.isNotEmpty ?? false);
    if (kIsWeb) {
      var webUrl = Uri.base.toString() + webReturnPath;
      debugPrint(webUrl);
      return webUrl;
    } else {
      final requestId = Random.secure().nextInt(99999999);
      return '$_returnUrlForSca?requestId=$requestId';
    }
  }

  /// Authenticate a SetupIntent
  /// https://stripe.com/docs/api/setup_intents/confirm
  Future<Map<String, dynamic>> authenticateSetupIntent(String clientSecret, {String webReturnPath}) async {
    final intent = await api
        .confirmSetupIntent(clientSecret, data: {'return_url': getReturnUrlForSca(webReturnPath: webReturnPath)});
    if (intent['status'] == 'requires_action') {
      return _handleSetupIntent(intent['next_action']);
    } else {
      return Future.value(intent);
    }
  }

  /// Confirm and authenticate a SetupIntent
  /// https://stripe.com/docs/api/setup_intents/confirm
  Future<Map<String, dynamic>> confirmSetupIntent(String clientSecret, String paymentMethod,
      {String webReturnPath}) async {
    final intent = await api.confirmSetupIntent(clientSecret,
        data: {'return_url': getReturnUrlForSca(webReturnPath: webReturnPath), 'payment_method': paymentMethod});
    if (intent['status'] == 'requires_action') {
      return _handleSetupIntent(intent['next_action']);
    } else {
      return Future.value(intent);
    }
  }

  /// Confirm and authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android
  Future<Map<String, dynamic>> confirmPayment(String paymentIntentClientSecret, {String paymentMethodId}) async {
    final data = {'return_url': getReturnUrlForSca()};
    if (paymentMethodId != null) data['payment_method'] = paymentMethodId;
    final paymentIntent = await api.confirmPaymentIntent(paymentIntentClientSecret, data: data);
    if (paymentIntent['status'] == 'requires_action') {
      return authenticatePaymentWithNextAction(paymentIntent['next_action']);
    } else {
      return Future.value(paymentIntent);
    }
  }

  /// Authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android-manual
  Future<Map<String, dynamic>> authenticatePayment(String paymentIntentClientSecret) async {
    final paymentIntent = await api.retrievePaymentIntent(paymentIntentClientSecret);
    if (paymentIntent['status'] != 'requires_action') {
      return Future.value(paymentIntent);
    }
    final nextAction = paymentIntent['next_action'];
    return authenticatePaymentWithNextAction(nextAction);
  }

  /// Authenticate a payment with [nextAction].
  /// This is similar to [authenticatePayment] but is slightly more efficient,
  /// as it avoids the request to the Stripe API to retrieve the action.
  /// To use this, return the complete [nextAction] from your server.
  Future<Map<String, dynamic>> authenticatePaymentWithNextAction(Map nextAction) async {
    return _authenticateIntent(
        nextAction,
        (uri) => api.retrievePaymentIntent(
              uri.queryParameters['payment_intent_client_secret'],
            ));
  }

  /// Launch 3DS in a new browser window.
  /// Returns a [Future] with the Stripe SetupIntent when the user completes or cancels authentication.
  Future<Map<String, dynamic>> _handleSetupIntent(Map action) async {
    return _authenticateIntent(
        action,
        (uri) => api.retrieveSetupIntent(
              uri.queryParameters['setup_intent_client_secret'],
            ));
  }

  Future<Map<String, dynamic>> _authenticateIntent(Map action, IntentProvider callback) async {
    final url = action['redirect_to_url']['url'];
    final completer = Completer<Map<String, dynamic>>();
    if (!kIsWeb) {
      final returnUrl = Uri.parse(action['redirect_to_url']['return_url']);
      StreamSubscription sub;
      sub = getUriLinksStream().listen((Uri uri) async {
        if (uri.scheme == returnUrl.scheme &&
            uri.host == returnUrl.host &&
            uri.queryParameters['requestId'] == returnUrl.queryParameters['requestId']) {
          await sub.cancel();
          final intent = await callback(uri);
          completer.complete(intent);
        }
      });
    } else {
      completer.complete(null);
    }

    await launch(url, webOnlyWindowName: '_self');
    return completer.future;
  }
}
