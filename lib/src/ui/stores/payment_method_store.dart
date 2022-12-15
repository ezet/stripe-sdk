import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../customer_session.dart';
import '../screens/payment_methods_screen.dart';

/// A managed repository for payment methods.
/// This is the preferred way to work with payment methods when using Flutter.
/// The store will only refresh itself if there are active listeners.
class PaymentMethodStore extends ChangeNotifier {
  final List<PaymentMethod> paymentMethods = [];
  bool isLoading = false;
  bool isInitialized = false;

  /// The customer session the store operates on.
  final CustomerSession _customerSession;

  static PaymentMethodStore? _instance;

  /// Access the singleton instance of [PaymentMethodStore].
  static PaymentMethodStore get instance {
    _instance ??= PaymentMethodStore();
    return _instance!;
  }

  PaymentMethodStore({CustomerSession? customerSession})
      : _customerSession = customerSession ?? CustomerSession.instance {
    _customerSession.addListener(_customerSessionListener);
  }

  void _customerSessionListener() => dispose();

  /// Refreshes data from the API when the first listener is added.
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    if (!isInitialized) {
      isInitialized = true;
      refresh();
    }
  }

  /// Attach a payment method and refresh the store if there are any active listeners.
  Future<Map<String, dynamic>> attachPaymentMethod(String paymentMethodId) async {
    final paymentMethodFuture = await _customerSession.attachPaymentMethod(paymentMethodId);
    await refresh();
    return paymentMethodFuture;
  }

  /// Detach a payment method and refresh the store if there are any active listeners.
  Future<Map> detachPaymentMethod(String paymentMethodId) async {
    final paymentMethodFuture = await _customerSession.detachPaymentMethod(paymentMethodId);
    await refresh();
    return paymentMethodFuture;
  }

  /// Refresh the store if there are any active listeners.
  Future<void> refresh() async {
    final paymentMethodFuture = _customerSession.listPaymentMethods(limit: 100);
    isLoading = true;
    notifyListeners();
    return paymentMethodFuture.then((value) {
      final List listData = value['data'] ?? <PaymentMethod>[];
      paymentMethods.clear();
      if (listData.isNotEmpty) {
        paymentMethods.addAll(listData
            .map((item) => PaymentMethod(item['id'], item['card']['last4'], item['card']['brand'],
                DateTime(item['card']['exp_year'], item['card']['exp_month'])))
            .toList());
      }
    }).whenComplete(() {
      isLoading = false;
      notifyListeners();
    });
  }

  /// Clear the store, notify all active listeners and dispose the ChangeNotifier.
  @override
  void dispose() {
    _customerSession.removeListener(_customerSessionListener);
    paymentMethods.clear();
    notifyListeners();
    if (identical(this, _instance)) {
      _instance = null;
    }
    super.dispose();
  }
}
