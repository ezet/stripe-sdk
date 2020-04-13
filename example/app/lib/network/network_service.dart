import 'dart:convert';
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';

class NetworkService {
  final CloudFunctions _cf;

  NetworkService(this._cf);

  NetworkService.defaultInstance()
      : _cf = CloudFunctions(region: "europe-west2");

  /// Utility function to call a Firebase Function
  Future<T> _call<T>(String name, Map params) async {
    log('GlappenService._call, $name, $params');
    final HttpsCallable callable = _cf.getHttpsCallable(
      functionName: name,
    );
    try {
      final result = await callable.call(params);
      print(result);
      print(result.data);
      return result.data;
    } on CloudFunctionsException catch (e) {
      log(e.message);
      log(e.toString());
      return null;
    }
  }

  /// Get a stripe ephemeral key
  Future<String> getEphemeralKey(String apiVersion) async {
    final result =
        await _call('getEphemeralKey', {'stripeversion': apiVersion});
    final key = result['key'];
    final jsonKey = json.encode(key);
    return jsonKey;
  }

  Future<Map> createSetupIntent(String paymentMethod) {
    final params = {'payment_method': paymentMethod};
    return _call('createSetupIntent', params);
  }
}
