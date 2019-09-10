import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:stripe_sdk/src/ephemeral_key_manager.dart';
import 'package:stripe_sdk/src/stripe_api_handler.dart';



class Stripe {
  static Stripe _instance;

  final StripeApiHandler _apiHandler = StripeApiHandler();

  final String publishableKey;
  String stripeAccount;

  Stripe._internal(this.publishableKey);

  static void init(String publishableKey) {
    if (_instance == null) {
      _validateKey(publishableKey);
      _instance = new Stripe._internal(publishableKey);
    }
  }

  static Stripe get instance {
    if (_instance == null) {
      throw new Exception(
          "Attempted to get instance of Stripe without initialization");
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
  Future<Map<dynamic, dynamic>> retrievePaymentIntent(
      String intent, String clientSecret) async {
    return _apiHandler.retrievePaymentIntent(
        publishableKey, intent, clientSecret);
  }

  static void _validateKey(String publishableKey) {
    if (publishableKey == null || publishableKey.isEmpty) {
      throw new Exception("Invalid Publishable Key: " +
          "You must use a valid publishable key to create a token.  " +
          "For more info, see https://stripe.com/docs/stripe.js.");
    }

    if (publishableKey.startsWith("sk_")) {
      throw new Exception("Invalid Publishable Key: " +
          "You are using a secret key to create a token, " +
          "instead of the publishable one. For more info, " +
          "see https://stripe.com/docs/stripe.js");
    }
  }
}

class CustomerSession {
  static final int KEY_REFRESH_BUFFER_IN_SECONDS = 30;

  static CustomerSession _instance;

  final StripeApiHandler _apiHandler = new StripeApiHandler();

  final EphemeralKeyManager _keyManager;

  CustomerSession._internal(this._keyManager);

  /// Initiate a new customer session
  static void initCustomerSession(EphemeralKeyProvider provider) {
    if (_instance == null) {
      final manager =
          new EphemeralKeyManager(provider, KEY_REFRESH_BUFFER_IN_SECONDS);
      _instance = new CustomerSession._internal(manager);
    }
  }

  /// End the current active customer session
  static void endCustomerSession() {
    _instance = null;
  }

  /// Get the current customer session
  static CustomerSession get instance {
    if (_instance == null) {
      throw new Exception(
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
    return _apiHandler.attachPaymentMethod(
        key.customerId, paymentMethodId, key.secret);
  }

  Future<Map<dynamic, dynamic>> retrievePaymentIntent(
      String intent, String clientSecret) async {
    final key = await _keyManager.retrieveEphemeralKey();
    return _apiHandler.retrievePaymentIntent(key.secret, intent, clientSecret);
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
}
