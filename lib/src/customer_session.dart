import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'ephemeral_key_manager.dart';
import 'stripe_api_handler.dart';

class CustomerSession extends ChangeNotifier {
  static final int keyRefreshBufferInSeconds = 30;

  static CustomerSession _instance;

  final StripeApiHandler _apiHandler;

  final EphemeralKeyManager _keyManager;
  final String apiVersion;

  bool isDisposed = false;

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
    _instance = CustomerSession._(provider, apiVersion: apiVersion, stripeAccount: stripeAccount);
    if (prefetchKey) {
      _instance._keyManager.retrieveEphemeralKey();
    }
  }

  /// End the managed singleton customer session.
  /// Call this when the current user logs out.
  @Deprecated('Use CustomerSession.instance.endSession instead.')
  static void endCustomerSession() {
    _instance.endSession();
  }

  /// End the managed singleton customer session.
  /// Call this when the current user logs out.
  void endSession() {
    notifyListeners();
    dispose();
    isDisposed = true;
    if (this == _instance) _instance = null;
  }

  /// Get the current customer session
  static CustomerSession get instance {
    if (_instance == null) {
      throw Exception('Attempted to get instance of CustomerSession before initialization.'
          'Please initialize a new session using [CustomerSession.initCustomerSession() first.]');
    }
    assert(_instance._assertNotDisposed());
    return _instance;
  }

  /// Retrieves the details for the current customer.
  /// https://stripe.com/docs/api/customers/retrieve
  Future<Map<String, dynamic>> retrieveCurrentCustomer() async {
    assert(_assertNotDisposed());
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/customers/${key.customerId}';
    return _apiHandler.request(RequestMethod.get, path, key.secret, apiVersion);
  }

  /// List a Customer's PaymentMethods.
  /// https://stripe.com/docs/api/payment_methods/list
  Future<Map<String, dynamic>> listPaymentMethods(
      {type = 'card', int limit, String ending_before, String starting_after}) async {
    assert(_assertNotDisposed());
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/payment_methods';
    final params = {'customer': key.customerId, 'type': type};
    if (limit != null) params['limit'] = limit;
    if (starting_after != null) params['starting_after'] = starting_after;
    if (ending_before != null) params['ending_before'] = ending_before;
    return _apiHandler.request(RequestMethod.get, path, key.secret, apiVersion, params: params);
  }

  /// Attach a PaymentMethod.
  /// https://stripe.com/docs/api/payment_methods/attach
  Future<Map<String, dynamic>> attachPaymentMethod(String paymentMethodId) async {
    assert(_assertNotDisposed());
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/payment_methods/$paymentMethodId/attach';
    final params = {'customer': key.customerId};
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion, params: params);
  }

  /// Detach a PaymentMethod.
  /// https://stripe.com/docs/api/payment_methods/detach
  Future<Map<String, dynamic>> detachPaymentMethod(String paymentMethodId) async {
    assert(_assertNotDisposed());
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/payment_methods/$paymentMethodId/detach';
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion);
  }

  /// Attaches a Source object to the Customer.
  /// The source must be in a chargeable or pending state.
  /// https://stripe.com/docs/api/sources/attach
  Future<Map<String, dynamic>> attachSource(String sourceId) async {
    assert(_assertNotDisposed());
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/customers/${key.customerId}/sources';
    final params = {'source': sourceId};
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion, params: params);
  }

  /// Detaches a Source object from a Customer.
  /// The status of a source is changed to consumed when it is detached and it can no longer be used to create a charge.
  /// https://stripe.com/docs/api/sources/detach
  Future<Map<String, dynamic>> detachSource(String sourceId) async {
    assert(_assertNotDisposed());
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/customers/${key.customerId}/sources/$sourceId';
    return _apiHandler.request(RequestMethod.delete, path, key.secret, apiVersion);
  }

  /// Updates the specified customer by setting the values of the parameters passed.
  /// https://stripe.com/docs/api/customers/update
  Future<Map<String, dynamic>> updateCustomer(Map<String, dynamic> data) async {
    assert(_assertNotDisposed());
    final key = await _keyManager.retrieveEphemeralKey();
    final path = '/customers/${key.customerId}';
    return _apiHandler.request(RequestMethod.post, path, key.secret, apiVersion, params: data);
  }

  bool _assertNotDisposed() {
    assert(() {
      if (isDisposed) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }
}
