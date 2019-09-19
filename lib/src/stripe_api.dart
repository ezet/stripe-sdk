import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:stripe_sdk/src/3ds_auth.dart';
import 'package:stripe_sdk/src/ephemeral_key_manager.dart';
import 'package:stripe_sdk/src/stripe_api_handler.dart';

class Stripe {
  static Stripe _instance;

  final StripeApiHandler _apiHandler = StripeApiHandler();

  final String publishableKey;
  String stripeAccount;

  /// Create a new instance, which can be used with e.g. dependency injection.
  Stripe(this.publishableKey, {String apiVersion = DEFAULT_API_VERSION}) {
      _validateKey(publishableKey);
    _apiHandler.apiVersion = apiVersion;
  }

  /// Initialize the managed singleton instance.
  static void init(String publishableKey,
      {String apiVersion = DEFAULT_API_VERSION}) {
    if (_instance == null) {
      _instance = Stripe(publishableKey, apiVersion: apiVersion);
    }
  }

  static Stripe get instance {
    if (_instance == null) {
      throw Exception(
          "Attempted to get singleton instance of Stripe without initialization");
    }
    return _instance;
  }

  /// Create a stripe Token
  /// https://stripe.com/docs/api/tokens
  Future<Map<String, dynamic>> createToken(Map data) async {
    final token = await _apiHandler.createToken(data, publishableKey);
    return token;
  }

  /// Create a PaymenMethod.
  /// https://stripe.com/docs/api/payment_methods/create
  Future<Map<String, dynamic>> createPaymentMethod(
      Map<String, dynamic> cardMap) async {
    debugPrint(cardMap.toString());
    return _apiHandler.createPaymentMethod(publishableKey, cardMap);
  }

  /// Retrieve a PaymentIntent.
  /// https://stripe.com/docs/api/payment_intents/retrieve
  Future<Map<String, dynamic>> retrievePaymentIntent(
      String clientSecret) async {
    final intentId = _parseIdFromClientSecret(clientSecret);
    return _apiHandler.retrievePaymentIntent(
        publishableKey, intentId, clientSecret);
  }

  static void _validateKey(String publishableKey) {
    if (publishableKey == null || publishableKey.isEmpty) {
      throw Exception("Invalid Publishable Key: " +
          "You must use a valid publishable key to create a token.  " +
          "For more info, see https://stripe.com/docs/stripe.js.");
    }

    if (publishableKey.startsWith("sk_")) {
      throw Exception("Invalid Publishable Key: " +
          "You are using a secret key to create a token, " +
          "instead of the publishable one. For more info, " +
          "see https://stripe.com/docs/stripe.js");
    }
  }

  /// Creates a return URL that can be used to authenticate a single PaymentIntent.
  /// This should be set on the intent before attempting to authenticate it.
  static String getReturnUrl() {
    final requestId = Random.secure().nextInt(99999999);
    return "stripesdk://3ds.stripesdk.io?requestId=$requestId";
  }
}

class CustomerSession {
  static final int KEY_REFRESH_BUFFER_IN_SECONDS = 30;

  static CustomerSession _instance;

  final StripeApiHandler _apiHandler = StripeApiHandler();

  final EphemeralKeyManager _keyManager;

  CustomerSession._internal(this._keyManager);

  /// Initiate a new customer session
  static void initCustomerSession(EphemeralKeyProvider provider) {
    if (_instance == null) {
      final manager =
          EphemeralKeyManager(provider, KEY_REFRESH_BUFFER_IN_SECONDS);
      _instance = CustomerSession._internal(manager);
    }
  }

  /// End the current active customer session
  static void endCustomerSession() {
    _instance = null;
  }

  /// Get the current customer session
  static CustomerSession get instance {
    if (_instance == null) {
      throw Exception(
          "Attempted to get instance of CustomerSession without initialization.");
    }
    return _instance;
  }

  /// Retrieves the details for the current customer.
  /// https://stripe.com/docs/api/customers/retrieve
  Future<Map<String, dynamic>> retrieveCurrentCustomer() async {
    final key = await _keyManager.retrieveEphemeralKey();
    return _apiHandler.retrieveCustomer(key.customerId, key.secret);
  }

  /// List a Customer's PaymentMethods.
  /// https://stripe.com/docs/api/payment_methods/list
  Future<Map<String, dynamic>> listPaymentMethods() async {
    final key = await _keyManager.retrieveEphemeralKey();
    return _apiHandler.listPaymentMethods(key.customerId, key.secret);
  }

  /// Attach a PaymenMethod.
  /// https://stripe.com/docs/api/payment_methods/attach
  Future<Map<String, dynamic>> attachPaymentMethod(
      String paymentMethodId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    return _apiHandler.attachPaymentMethod(
        key.customerId, key.secret, paymentMethodId);
  }

  /// Detach a PaymentMethod.
  /// https://stripe.com/docs/api/payment_methods/detach
  Future<Map<String, dynamic>> detachPaymentMethod(
      String paymentMethodId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    return _apiHandler.detachPaymentMethod(paymentMethodId, key.secret);
  }

  /// Confirm a PaymentIntent
  /// https://stripe.com/docs/api/payment_intents/confirm
  Future<Map<String, dynamic>> confirmPaymentIntent(
      String intent, String clientSecret,
      {Map<String, dynamic> data = const {}}) async {
    final key = await _keyManager.retrieveEphemeralKey();
    data['client_secret'] = clientSecret;
    return _apiHandler.confirmPaymentIntent(key.secret, intent, data);
  }

  /// Attaches a Source object to the Customer.
  /// The source must be in a chargeable or pending state.
  /// https://stripe.com/docs/api/sources/attach
  Future<Map<String, dynamic>> attachSource(String sourceId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    return _apiHandler.attachSource(key.customerId, sourceId, key.secret);
  }

  /// Detaches a Source object from a Customer.
  /// The status of a source is changed to consumed when it is detached and it can no longer be used to create a charge.
  /// https://stripe.com/docs/api/sources/detach
  Future<Map<String, dynamic>> detachSource(String sourceId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    return _apiHandler.detachSource(key.customerId, sourceId, key.secret);
  }

  /// Updates the specified customer by setting the values of the parameters passed.
  /// https://stripe.com/docs/api/customers/update
  Future<Map<String, dynamic>> updateCustomerDefaultSource(
      Map<String, dynamic> data) async {
    final key = await _keyManager.retrieveEphemeralKey();
    return _apiHandler.updateCustomer(key.customerId, data, key.secret);
  }

  /// Confirm and authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android
  Future<Map<String, dynamic>> confirmPayment(
      String paymentIntentClientSecret, String paymentMethodId) async {
    final paymentIntentId = _parseIdFromClientSecret(paymentIntentClientSecret);
    final paymentIntent =
        await confirmPaymentIntent(paymentIntentId, paymentIntentClientSecret);
    if (paymentIntent['status'] == "requires_action") {
      return launch3ds(paymentIntent['next_action']);
    } else {
      return Future.value(paymentIntent);
    }
  }

  /// Authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android-manual
  Future<Map<String, dynamic>> authenticatePayment(
      String paymentIntentClientSecret) async {
    final paymentIntent =
        await Stripe.instance.retrievePaymentIntent(paymentIntentClientSecret);
    if (paymentIntent['status'] == "requires_action") {
      return launch3ds(paymentIntent['next_action']);
    } else {
      return Future.value(paymentIntent);
    }
  }
}

String _parseIdFromClientSecret(String clientSecret) {
  return clientSecret.split("_secret")[0];
}

String getRedirectUrl() {
  return "stripesdk://paymentintent.3ds";
}
