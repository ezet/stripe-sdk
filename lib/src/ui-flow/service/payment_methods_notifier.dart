import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/ui-flow/model/payment_method_models.dart';

import '../../../stripe_sdk.dart';
import '../../customer_session.dart';
import '../../util/stripe_text_utils.dart';

/*This class is similar to PaymentMethodStore class except with some modifications. I didn't want to change the original file as it breaks few things in the example flutter app and gets a bit messy. Ideally, these 2 classes should be integrated with each other down the line.
*/

class PaymentMethodsNotifier extends ChangeNotifier {
  static PaymentMethodsNotifier _instance;
  final CustomerSession _customerSession;

  static PaymentMethodsNotifier get instance {
    return _instance ??= PaymentMethodsNotifier();
  }

  PaymentMethodsNotifier() : _customerSession = CustomerSession.instance {
    if (_customerSession == null) {
      throw Exception(
          'CustomerSession instance needs to be initialized before accessing PaymentMethodsNotifier class');
    }
  }

  /// Attach a payment method and refresh the store if there are any active listeners.
  Future<Map> attachPaymentMethod(String paymentMethodId) {
    //Check paymentMethodId isn't null before api request
    if (isBlank(paymentMethodId)) {
      final paymentMethodFuture =
          _customerSession.attachPaymentMethod(paymentMethodId);
      refresh();
      return paymentMethodFuture;
    }
    throw Exception('paymentMethodId is not found');
  }

  /// Detach a payment method and refresh the store if there are any active listeners.
  Future<Map> detachPaymentMethod(String paymentMethodId) {
    if (isBlank(paymentMethodId)) {
      final paymentMethodFuture =
          _customerSession.detachPaymentMethod(paymentMethodId);
      refresh();
      return paymentMethodFuture;
    }
    throw Exception('paymentMethodId is not found');
  }

  //Get list of available payment methods
  Future<PaymentMethodsListModel> getPaymentMethods() async {
    final paymentMethodFuture = await _customerSession.listPaymentMethods();
    return PaymentMethodsListModel.fromJsonToList(paymentMethodFuture);
  }

  //Get the default payment method
  Future<PaymentMethodModel> get deafultPaymentMethod async {
    final data = await getPaymentMethods();
    final paymentList = data.data;
    return paymentList.isEmpty ? null : paymentList[0];
  }

  void refresh() {
    super.notifyListeners();
  }
}
