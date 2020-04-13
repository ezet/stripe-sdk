import 'dart:async';
import 'dart:math';

import 'package:stripe_sdk/src/customer_session.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ephemeral_key_manager.dart';
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
  /// [returnUrlForSca] can be used to use your own return url for
  /// Strong Customer Authentication (SCA) such as 3DS, 3DS2, BankID and others.
  /// It is recommended to use your own app specific url scheme and host.
  Stripe(String publishableKey, {String stripeAccount, String returnUrlForSca})
      : api = StripeApi(publishableKey, stripeAccount: stripeAccount),
        _returnUrlForSca = returnUrlForSca ?? null;

  final StripeApi api;
  final String _returnUrlForSca;
  static Stripe _instance;

  /// Access the instance of Stripe by calling [Stripe.instance].
  /// Throws an [Exception] if [Stripe.init] hasn't been called previously.
  static Stripe get instance {
    if (_instance == null) {
      throw Exception("Attempted to get singleton instance of Stripe without initialization");
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
  /// [returnUrlForSca] can be used to use your own return url for
  /// Strong Customer Authentication (SCA) such as 3DS, 3DS2, BankID and others.
  /// It is recommended to use your own app specific url scheme and host. This
  /// parameter must match your "android/app/src/main/AndroidManifest.xml"
  /// and "ios/Runner/Info.plist" configuration.
  static void init(String publishableKey, {String stripeAccount, String returnUrlForSca}) {
    _instance = Stripe(publishableKey, stripeAccount: stripeAccount, returnUrlForSca: returnUrlForSca);
    StripeApi.init(publishableKey, stripeAccount: stripeAccount);
  }

  CustomerSession getCustomerSession(EphemeralKeyProvider provider) {
    return CustomerSession(provider);
  }

  /// Creates a return URL that can be used to authenticate a single PaymentIntent.
  /// This should be set on the intent before attempting to authenticate it.
  String getReturnUrlForSca() {
    final requestId = Random.secure().nextInt(99999999);
    return "$_returnUrlForSca?requestId=$requestId";
  }

  @Deprecated("Use `Stripe.instance.getReturnUrlForSca()` instead. Due for removal in version 3.0.")
  static String getReturnUrl() {
    final requestId = Random.secure().nextInt(99999999);
    return "stripesdk://3ds.stripesdk.io?requestId=$requestId";
  }

  /// Confirm a SetupIntent
  /// https://stripe.com/docs/api/setup_intents/confirm
  Future<Map<String, dynamic>> confirmSetupIntent(String clientSecret) async {
    final intent = await api.confirmSetupIntent(clientSecret, data: {'return_url': getReturnUrlForSca()});
    if (intent['status'] == 'requires_action') {
      return handleSetupIntent(intent['next_action']);
    } else {
      return Future.value(intent);
    }
  }

  /// Confirm a SetupIntent with a PaymentMethod
  /// https://stripe.com/docs/api/setup_intents/confirm
  Future<Map<String, dynamic>> confirmSetupIntentWithPaymentMethod(String clientSecret, String paymentMethod) async {
    final intent = await api
        .confirmSetupIntent(clientSecret, data: {'return_url': getReturnUrlForSca(), 'payment_method': paymentMethod});
    if (intent['status'] == 'requires_action') {
      return handleSetupIntent(intent['next_action']);
    } else {
      return Future.value(intent);
    }
  }

  /// Confirm and authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android
  Future<Map<String, dynamic>> confirmPayment(String paymentIntentClientSecret, String paymentMethodId) async {
    final paymentIntent = await api.confirmPaymentIntent(paymentIntentClientSecret,
        data: {'return_url': getReturnUrlForSca(), 'payment_method': paymentMethodId});
    if (paymentIntent['status'] == "requires_action") {
      return handlePaymentIntent(paymentIntent['next_action']);
    } else {
      return Future.value(paymentIntent);
    }
  }

  /// Authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android-manual
  Future<Map<String, dynamic>> authenticatePayment(String paymentIntentClientSecret) async {
    final paymentIntent = await api.retrievePaymentIntent(paymentIntentClientSecret);
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
        (uri) => api.retrievePaymentIntent(
              uri.queryParameters['payment_intent_client_secret'],
            ));
  }

  /// Launch 3DS in a new browser window.
  /// Returns a [Future] with the Stripe SetupIntent when the user completes or cancels authentication.
  Future<Map<String, dynamic>> handleSetupIntent(Map action) async {
    return _authenticateIntent(
        action,
        (uri) => api.retrieveSetupIntent(
              uri.queryParameters['setup_intent_client_secret'],
            ));
  }

  Future<Map<String, dynamic>> _authenticateIntent(Map action, IntentProvider callback) async {
    final url = action['redirect_to_url']['url'];
    final returnUrl = Uri.parse(action['redirect_to_url']['return_url']);
    final completer = Completer<Map<String, dynamic>>();
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

    await launch(url);
    return completer.future;
  }
}
