import 'dart:async';
import 'dart:math';

import 'package:stripe_sdk/src/3ds_auth.dart';
import 'package:stripe_sdk/src/ephemeral_key_manager.dart';
import 'package:stripe_sdk/src/stripe_api_handler.dart';

class Stripe {
  static Stripe _instance;

  final StripeApiHandler _apiHandler = StripeApiHandler();

  final String publishableKey;
  String stripeAccount;

  final String apiVersion;

  /// Create a new instance, which can be used with e.g. dependency injection.
  Stripe(this.publishableKey, {this.apiVersion = DEFAULT_API_VERSION}) {
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
  Future<Map<String, dynamic>> createToken(Map<String, dynamic> data) async {
    final path = "/tokens";
    return _apiHandler.request(
        RequestMethod.post, path, publishableKey, apiVersion,
        params: data);
  }

  /// Create a PaymenMethod.
  /// https://stripe.com/docs/api/payment_methods/create
  Future<Map<String, dynamic>> createPaymentMethod(
      Map<String, dynamic> data) async {
    final path = "/payment_methods";
    return _apiHandler.request(
        RequestMethod.post, path, publishableKey, apiVersion,
        params: data);
  }

  /// Retrieve a PaymentIntent.
  /// https://stripe.com/docs/api/payment_intents/retrieve
  Future<Map<String, dynamic>> retrievePaymentIntent(String clientSecret,
      {String apiVersion}) async {
    final intentId = _parseIdFromClientSecret(clientSecret);
    final path = "/payment_intents/$intentId";
    final params = {'client_secret': clientSecret};
    return _apiHandler.request(
        RequestMethod.get, path, publishableKey, apiVersion,
        params: params);
  }

  /// Retrieve a SetupIntent.
  /// https://stripe.com/docs/api/setup_intents/retrieve
  Future<Map<String, dynamic>> retrieveSetupIntent(String clientSecret,
      {String apiVersion}) async {
    final intentId = _parseIdFromClientSecret(clientSecret);
    final path = "/setup_intents/$intentId";
    final params = {'client_secret': clientSecret};
    return _apiHandler.request(
        RequestMethod.get, path, publishableKey, apiVersion,
        params: params);
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
   static final int keyRefreshBufferInSeconds = 30;

  static CustomerSession _instance;

  final StripeApiHandler _apiHandler = StripeApiHandler();

  final EphemeralKeyManager _keyManager;
  final String apiVersion;

  /// Create a new CustomerSession instance. Use this if you prefer to manage your own instances.
  CustomerSession(this._keyManager, {this.apiVersion = DEFAULT_API_VERSION}) {
    _apiHandler.apiVersion = apiVersion;
  }

  /// Initiate the customer session singleton instance.
  static void initCustomerSession(EphemeralKeyProvider provider,
      {String apiVersion = DEFAULT_API_VERSION}) {
    if (_instance == null) {
      final manager =
          EphemeralKeyManager(provider, keyRefreshBufferInSeconds);
      _instance = CustomerSession(manager, apiVersion: apiVersion);
    }
  }

  /// End the managed singleton customer session.
  static void endCustomerSession() {
    _instance = null;
  }

  /// Get the current customer session
  static CustomerSession get instance {
    if (_instance == null) {
      throw Exception(
          "Attempted to get singleton instance of CustomerSession without initialization.");
    }
    return _instance;
  }

  /// Retrieves the details for the current customer.
  /// https://stripe.com/docs/api/customers/retrieve
  Future<Map<String, dynamic>> retrieveCurrentCustomer() async {
    final key = await _keyManager.retrieveEphemeralKey();
    final String url = "/customers/${key.customerId}";
    return _apiHandler.request(RequestMethod.get, url, key.secret, apiVersion);
  }

  /// List a Customer's PaymentMethods.
  /// https://stripe.com/docs/api/payment_methods/list
  Future<Map<String, dynamic>> listPaymentMethods() async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = "/payment_methods";
    final params = {'customer': key.customerId, 'type': 'card'};
    return _apiHandler.request(RequestMethod.get, path, key.secret, apiVersion,
        params: params);
  }

  /// Attach a PaymenMethod.
  /// https://stripe.com/docs/api/payment_methods/attach
  Future<Map<String, dynamic>> attachPaymentMethod(
      String paymentMethodId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = "/payment_methods/$paymentMethodId/attach";
    final params = {'customer': key.customerId};
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion,
        params: params);
  }

  /// Detach a PaymentMethod.
  /// https://stripe.com/docs/api/payment_methods/detach
  Future<Map<String, dynamic>> detachPaymentMethod(
      String paymentMethodId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = "/payment_methods/$paymentMethodId/detach";
    return _apiHandler.request(
        RequestMethod.post, path, key.secret, apiVersion);
  }

  /// Confirm a PaymentIntent
  /// https://stripe.com/docs/api/payment_intents/confirm
  Future<Map<String, dynamic>> confirmPaymentIntent(String clientSecret,
      {Map<String, dynamic> data = const {}}) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final intent = _parseIdFromClientSecret(clientSecret);
    data['client_secret'] = clientSecret;
    final path = "/payment_intents/$intent/confirm";
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion,
        params: data);
  }

  /// Confirm a SetupIntent
  /// https://stripe.com/docs/api/setup_intents/confirm
  Future<Map<String, dynamic>> confirmSetupIntent(String clientSecret,
      {Map<String, dynamic> data = const {}}) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final intent = _parseIdFromClientSecret(clientSecret);
    data['client_secret'] = clientSecret;
    final path = "/setup_intents/$intent/confirm";
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion,
        params: data);
  }

  /// Attaches a Source object to the Customer.
  /// The source must be in a chargeable or pending state.
  /// https://stripe.com/docs/api/sources/attach
  Future<Map<String, dynamic>> attachSource(String sourceId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final String url = "/customers/${key.customerId}/sources";
    final params = {'source': sourceId};
    return _apiHandler.request(RequestMethod.post, url, key.secret, apiVersion,
        params: params);
  }

  /// Detaches a Source object from a Customer.
  /// The status of a source is changed to consumed when it is detached and it can no longer be used to create a charge.
  /// https://stripe.com/docs/api/sources/detach
  Future<Map<String, dynamic>> detachSource(String sourceId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final String url = "/customers/${key.customerId}/sources/$sourceId";
    return _apiHandler.request(
        RequestMethod.delete, url, key.secret, apiVersion);
  }

  /// Updates the specified customer by setting the values of the parameters passed.
  /// https://stripe.com/docs/api/customers/update
  Future<Map<String, dynamic>> updateCustomer(Map<String, dynamic> data) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final String url = "/customers/${key.customerId}";
    return _apiHandler.request(RequestMethod.post, url, key.secret, apiVersion,
        params: data);
  }

  /// Confirm and authenticate a payment.
  /// Returns the PaymentIntent.
  /// https://stripe.com/docs/payments/payment-intents/android
  Future<Map<String, dynamic>> confirmPayment(
      String paymentIntentClientSecret, String paymentMethodId) async {
    final paymentIntent = await confirmPaymentIntent(paymentIntentClientSecret);
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
