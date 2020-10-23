import 'dart:async';

import 'ephemeral_key_manager.dart';
import 'stripe_api_handler.dart';

class CustomerSession {
  static final int keyRefreshBufferInSeconds = 30;

  static CustomerSession _instance;

  final StripeApiHandler _apiHandler;

  final EphemeralKeyManager _keyManager;
  final String apiVersion;

  /// Create a new CustomerSession instance. Use this if you prefer to manage your own instances.
  CustomerSession._(EphemeralKeyProvider provider, {this.apiVersion = DEFAULT_API_VERSION, String stripeAccount})
      : _keyManager = EphemeralKeyManager(provider, keyRefreshBufferInSeconds),
        _apiHandler = StripeApiHandler(stripeAccount: stripeAccount) {
    _apiHandler.apiVersion = apiVersion;
    _instance ??= this;
  }

  /// Initiate the customer session singleton instance.
  /// If [prefetchKey] is true, fetch the ephemeral key immediately.
  static void initCustomerSession(EphemeralKeyProvider provider,
      {String apiVersion = DEFAULT_API_VERSION, String stripeAccount, prefetchKey = true}) {
    // ignore: deprecated_member_use_from_same_package
    _instance = CustomerSession._(provider, apiVersion: apiVersion, stripeAccount: stripeAccount);
    if (prefetchKey) {
      _instance._keyManager.retrieveEphemeralKey();
    }
  }

  /// End the managed singleton customer session.
  /// Call this when the current user logs out.
  static void endCustomerSession() {
    _instance = null;
  }

  /// Get the current customer session
  static CustomerSession get instance {
    if (_instance == null) {
      throw Exception('Attempted to get instance of CustomerSession before initialization.'
          'Please initialize a new session using [CustomerSession.initCustomerSession() first.]');
    }
    return _instance;
  }

  /// Retrieves the details for the current customer.
  /// https://stripe.com/docs/api/customers/retrieve
  Future<Map<String, dynamic>> retrieveCurrentCustomer() async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/customers/${key.customerId}';
    return _apiHandler.request(RequestMethod.get, path, key.secret, apiVersion);
  }

  /// List a Customer's PaymentMethods.
  /// https://stripe.com/docs/api/payment_methods/list
  Future<Map<String, dynamic>> listPaymentMethods() async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/payment_methods';
    final params = {'customer': key.customerId, 'type': 'card'};
    return _apiHandler.request(RequestMethod.get, path, key.secret, apiVersion, params: params);
  }

  /// Attach a PaymenMethod.
  /// https://stripe.com/docs/api/payment_methods/attach
  Future<Map<String, dynamic>> attachPaymentMethod(String paymentMethodId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/payment_methods/$paymentMethodId/attach';
    final params = {'customer': key.customerId};
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion, params: params);
  }

  /// Detach a PaymentMethod.
  /// https://stripe.com/docs/api/payment_methods/detach
  Future<Map<String, dynamic>> detachPaymentMethod(String paymentMethodId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/payment_methods/$paymentMethodId/detach';
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion);
  }

  /// Attaches a Source object to the Customer.
  /// The source must be in a chargeable or pending state.
  /// https://stripe.com/docs/api/sources/attach
  Future<Map<String, dynamic>> attachSource(String sourceId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/customers/${key.customerId}/sources';
    final params = {'source': sourceId};
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion, params: params);
  }

  /// Detaches a Source object from a Customer.
  /// The status of a source is changed to consumed when it is detached and it can no longer be used to create a charge.
  /// https://stripe.com/docs/api/sources/detach
  Future<Map<String, dynamic>> detachSource(String sourceId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/customers/${key.customerId}/sources/$sourceId';
    return _apiHandler.request(RequestMethod.delete, path, key.secret, apiVersion);
  }

  /// Updates the specified customer by setting the values of the parameters passed.
  /// https://stripe.com/docs/api/customers/update
  Future<Map<String, dynamic>> updateCustomer(Map<String, dynamic> data) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/customers/${key.customerId}';
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion, params: data);
  }
}
