import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_sdk/src/stripe_error.dart';

const String DEFAULT_API_VERSION = "2019-08-14 ";

enum RequestMethod { get, post, put, delete, option }

class StripeApiHandler {
  static const String LIVE_API_BASE = "https://api.stripe.com";
  static const String LIVE_LOGGING_BASE = "https://q.stripe.com";
  static const String LOGGING_ENDPOINT = "https://m.stripe.com/4";
  static const String LIVE_API_PATH = LIVE_API_BASE + "/v1";

  static const String CHARSET = "UTF-8";
  static const String CUSTOMERS = "customers";
  static const String TOKENS = "tokens";
  static const String SOURCES = "sources";

  static const String VERSION_NAME = "27";

  static const String HEADER_KEY_REQUEST_ID = "Request-Id";
  static const String FIELD_ERROR = "error";
  static const String FIELD_SOURCE = "source";

  String apiVersion = DEFAULT_API_VERSION;

  static const String MALFORMED_RESPONSE_MESSAGE =
      "An improperly formatted error response was found.";

  final http.Client _client = http.Client();

  factory StripeApiHandler() {
    return StripeApiHandler._internal();
  }

  StripeApiHandler._internal();

  Future<Map<String, dynamic>> createToken(
      Map params, String publishableKey) async {
    final url = "$LIVE_API_PATH/tokens";
    final options = RequestOptions(key: publishableKey, apiVersion: apiVersion);
    return _getStripeResponse(RequestMethod.post, url, options, params: params);
  }

  Future<Map<String, dynamic>> retrievePaymentIntent(
      String publishableKey, String intent, String clientSecret) {
    final url = "$LIVE_API_PATH/payment_intents/$intent";
    final options = RequestOptions(key: publishableKey, apiVersion: apiVersion);
    final params = {'client_secret': clientSecret};
    return _getStripeResponse(RequestMethod.get, url, options, params: params);
  }

  Future<Map<String, dynamic>> confirmPaymentIntent(
      String publishableKey, String intent, Map<String, dynamic> data) {
    final url = "$LIVE_API_PATH/payment_intents/$intent/confirm";
    final options = RequestOptions(key: publishableKey, apiVersion: apiVersion);
    return _getStripeResponse(RequestMethod.get, url, options, params: data);
  }

  Future<Map<String, dynamic>> createPaymentMethod(
      String publishableKey, Map<String, dynamic> data) async {
    final url = "$LIVE_API_PATH/payment_methods";
    final options = RequestOptions(key: publishableKey, apiVersion: apiVersion);
    return _getStripeResponse(RequestMethod.post, url, options, params: data);
  }

  Future<Map<String, dynamic>> attachPaymentMethod(
      String customerId, String ephemeralKey, String paymentMethod) async {
    final url = "$LIVE_API_PATH/payment_methods/$paymentMethod/attach";
    final options = RequestOptions(key: ephemeralKey, apiVersion: apiVersion);
    final params = {'customer': customerId};
    return _getStripeResponse(RequestMethod.post, url, options, params: params);
  }

  Future<Map<String, dynamic>> listPaymentMethods(
      String customerId, String ephemeralKey) async {
    final url = "$LIVE_API_PATH/payment_methods";
    final options = RequestOptions(key: ephemeralKey, apiVersion: apiVersion);
    final params = {'customer': customerId, 'type': 'card'};
    return _getStripeResponse(RequestMethod.get, url, options, params: params);
  }

  Future<Map<String, dynamic>> detachPaymentMethod(
      String paymentMethodId, String ephemeralKey) async {
    final url = "$LIVE_API_PATH/payment_methods/$paymentMethodId/detach";
    final options = RequestOptions(key: ephemeralKey, apiVersion: apiVersion);
    return _getStripeResponse(RequestMethod.post, url, options);
  }

  Future<Map<String, dynamic>> retrieveCustomer(
      String customerId, String ephemeralKey) async {
    final String url = "$LIVE_API_PATH/customers/$customerId";
    final options = RequestOptions(key: ephemeralKey, apiVersion: apiVersion);
    return _getStripeResponse(RequestMethod.get, url, options);
  }

  Future<Map<String, dynamic>> attachSource(
      String customerId, String sourceId, String ephemeralKey) async {
    final String url = "$LIVE_API_PATH/customers/$customerId/sources";
    final options = RequestOptions(key: ephemeralKey, apiVersion: apiVersion);
    return await _getStripeResponse(
      RequestMethod.post,
      url,
      options,
      params: {FIELD_SOURCE: sourceId},
    );
  }

  Future<Map<String, dynamic>> detachSource(
      String customerId, String sourceId, String ephemeralKey) async {
    final String url = "$LIVE_API_PATH/customers/$customerId/sources/$sourceId";
    final options = RequestOptions(key: ephemeralKey, apiVersion: apiVersion);
    return _getStripeResponse(RequestMethod.delete, url, options);
  }

  Future<Map<String, dynamic>> updateCustomer(
      String customerId, Map<String, dynamic> data, String ephemeralKey) async {
    final String url = "$LIVE_API_PATH/customers/$customerId";
    final options = RequestOptions(key: ephemeralKey, apiVersion: apiVersion);
    return _getStripeResponse(RequestMethod.post, url, options, params: data);
  }

  Future<Map<String, dynamic>> _getStripeResponse(
      RequestMethod method, final String url, final RequestOptions options,
      {final Map<String, dynamic> params}) async {
    final headers = _headers(options: options);

    http.Response response;

    switch (method) {
      case RequestMethod.get:
        String fUrl = url;
        if (params != null && params.isNotEmpty) {
          fUrl = "$url?${_encodeMap(params)}";
        }
        response = await _client.get(fUrl, headers: headers);
        break;

      case RequestMethod.post:
        response = await _client.post(
          url,
          headers: headers,
          body: params != null ? _urlEncodeMap(params) : null,
        );
        break;

      case RequestMethod.delete:
        response = await _client.delete(url, headers: headers);
        break;
      default:
        throw Exception("Request Method: $method not implemented");
    }

    final requestId = response.headers[HEADER_KEY_REQUEST_ID];

    final statusCode = response.statusCode;
    Map<String, dynamic> resp;
    try {
      resp = json.decode(response.body);
    } catch (error) {
      final stripeError = StripeAPIError(requestId,
          {StripeAPIError.FIELD_MESSAGE: MALFORMED_RESPONSE_MESSAGE});
      throw StripeAPIException(stripeError);
    }

    if (statusCode < 200 || statusCode >= 300) {
      final Map<String, dynamic> errBody = resp[FIELD_ERROR];
      final stripeError = StripeAPIError(requestId, errBody);
      throw StripeAPIException(stripeError);
    } else {
      return resp;
    }
  }

  ///
  ///
  ///
  static Map<String, String> _headers({RequestOptions options}) {
    final Map<String, String> headers = Map();
    headers["Accept-Charset"] = CHARSET;
    headers["Accept"] = "application/json";
    headers["Content-Type"] = "application/x-www-form-urlencoded";
    headers["User-Agent"] = "Stripe/v1 DartBindings/$VERSION_NAME";

    if (options != null) {
      headers["Authorization"] = "Bearer ${options.key}";
    }

    // debug headers
    Map<String, String> propertyMap = Map();
    propertyMap["os.name"] = defaultTargetPlatform.toString();
    //propertyMap["os.version"] = String.valueOf(Build.VERSION.SDK_INT));
    propertyMap["bindings.version"] = VERSION_NAME;
    propertyMap["lang"] = "Dart";
    propertyMap["publisher"] = "lars.dahl@gmail.com";

    headers["X-Stripe-Client-User-Agent"] = json.encode(propertyMap);

    if (options != null) {
      if (options.apiVersion != null) {
        headers["Stripe-Version"] = options.apiVersion;
      }

      if (options.stripeAccount != null) {
        headers["Stripe-Account"] = options.stripeAccount;
      }

      if (options.idempotencyKey != null) {
        headers["Idempotency-Key"] = options.idempotencyKey;
      }
    }

    return headers;
  }

  static String _encodeMap(Map<String, dynamic> params) {
    return params.keys
        .map((key) =>
            '${Uri.encodeComponent(key)}=${Uri.encodeComponent(params[key].toString())}')
        .join('&');
  }

  static String _urlEncodeMap(dynamic data) {
    StringBuffer urlData = StringBuffer("");
    bool first = true;
    void urlEncode(dynamic sub, String path) {
      if (sub is List) {
        for (int i = 0; i < sub.length; i++) {
          urlEncode(sub[i], "$path%5B%5D");
        }
      } else if (sub is Map) {
        sub.forEach((k, v) {
          if (path == "") {
            urlEncode(v, "${Uri.encodeQueryComponent(k)}");
          } else {
            urlEncode(v, "$path%5B${Uri.encodeQueryComponent(k)}%5D");
          }
        });
      } else {
        if (!first) {
          urlData.write("&");
        }
        first = false;
        urlData.write("$path=${Uri.encodeQueryComponent(sub.toString())}");
      }
    }

    urlEncode(data, "");
    return urlData.toString();
  }
}

class RequestOptions {
  static const String TYPE_QUERY = "source";
  static const String TYPE_JSON = "json_data";

  final String apiVersion;
  final String guid;
  final String idempotencyKey;
  final String key;
  final String requestType;
  final String stripeAccount;

  RequestOptions({
    @required this.apiVersion,
    this.guid,
    this.idempotencyKey,
    this.key,
    this.requestType,
    this.stripeAccount,
  });
}
