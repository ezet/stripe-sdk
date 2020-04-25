import 'package:flutter/widgets.dart';

import '../../customer_session.dart';
import '../screens/payment_methods_screen.dart';

class PaymentMethodStore extends ChangeNotifier {
  final List<PaymentMethod> paymentMethods = List();
  final CustomerSession _customerSession;

  PaymentMethodStore({CustomerSession customerSession})
      : _customerSession = customerSession ?? CustomerSession.instance;

  @override
  void addListener(VoidCallback listener) {
    var isFirstListener = !hasListeners;
    super.addListener(listener);
    if (isFirstListener) refresh();
  }

  void clear() {
    paymentMethods.clear();
  }

  Future<Map> attachPaymentMethod(String paymentMethodId) {
    final paymentMethodFuture = _customerSession.attachPaymentMethod(paymentMethodId);
    refresh();
    return paymentMethodFuture;
  }

  Future<Map> detachPaymentMethod(String paymentMethodId) {
    final paymentMethodFuture = _customerSession.detachPaymentMethod(paymentMethodId);
    refresh();
    return paymentMethodFuture;
  }

  Future<void> refresh() {
    if (!hasListeners) return Future.value();

    final paymentMethodFuture = _customerSession.listPaymentMethods();
    return paymentMethodFuture.then((value) {
      final List listData = value['data'] ?? List<PaymentMethod>();
      paymentMethods.clear();
      if (listData.isNotEmpty) {
        paymentMethods.addAll(
            listData.map((item) => PaymentMethod(item['id'], item['card']['last4'], item['card']['brand'])).toList());
      }
      notifyListeners();
    });
  }
}
