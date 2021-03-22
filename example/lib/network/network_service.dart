import 'dart:convert';
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

class NetworkService {
  final FirebaseFunctions _cf;

  NetworkService(this._cf);

  NetworkService.defaultInstance() : _cf = FirebaseFunctions.instanceFor(region: 'europe-west2');

  /// Utility function to call a Firebase Function
  Future<T?> _call<T>(String name, Map params) async {
    log('NetworkService._call, $name, $params');
    final callable = _cf.httpsCallable(name);
    try {
      final result = await callable.call(params);
      print(result);
      print(result.data);
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      log(e.message.toString());
      log(e.toString());
      return null;
    }
  }

  /// Get a stripe ephemeral key
  Future<String> getEphemeralKey(String apiVersion) async {
    final result = await _call('getEphemeralKey', {'stripeVersion': apiVersion});
    final key = result['key'];
    final jsonKey = json.encode(key);
    return jsonKey;
  }

  Future<IntentResponse> createSetupIntent() async {
    final response = await _call('createSetupIntent', {});
    return IntentResponse(response['status'], response['clientSecret']);
  }

  Future<IntentResponse> createSetupIntentWithPaymentMethod(paymentMethod, String returnUrl) async {
    final params = {'paymentMethod': paymentMethod, 'returnUrl': returnUrl};
    final response = await _call('createSetupIntent', params);
    return IntentResponse(response['status'], response['clientSecret']);
  }

  Future<IntentResponse> createAutomaticPaymentIntent(int amount) async {
    final params = {
      'amount': amount,
    };
    final response = await _call('createAutomaticPaymentIntent', params);
    return IntentResponse(response['status'], response['clientSecret']);
  }

  Future<Map?> createManualPaymentIntent(int amount, String paymentMethod, String returnUrl) {
    final params = {'amount': amount, 'paymentMethod': paymentMethod, 'returnUrl': returnUrl};
    return _call('createManualPaymentIntent', params);
  }
}
