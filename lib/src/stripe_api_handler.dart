import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_sdk/src/model/card.dart';
import 'package:stripe_sdk/src/stripe_error.dart';

import 'model/customer.dart';
import 'model/shipping_information.dart';
import 'model/source.dart';
import 'model/token.dart';

const String API_VERSION = "2019-08-14 ";

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

  static const String MALFORMED_RESPONSE_MESSAGE =
      "An improperly formatted error response was found.";

  final http.Client _client = http.Client();

  factory StripeApiHandler() {
    return StripeApiHandler._internal();
  }

  StripeApiHandler._internal();

  ///
  ///
  ///
  Future<Token> createToken(Map<String, dynamic> params, String publishableKey) async {
    final url = "$LIVE_API_PATH/tokens";
    final options = new RequestOptions(publishableApiKey: publishableKey);
    final response = await _getStripeResponse(RequestMethod.post, url, options, params: params);
    final token = new Token(response);
    return token;
  }

  Future<Map<String, dynamic>> retrievePaymentIntent(
      String publishableKey, String intent, String clientSecret) {
    final url = "$LIVE_API_PATH/payment_intents/$intent";
    final options = new RequestOptions(publishableApiKey: publishableKey);
    final params = {'client_secret': clientSecret};
    return _getStripeResponse(RequestMethod.get, url, options, params: params);
  }

  Future<Map<String, dynamic>> listPaymentMethods(String customerId, String publishableKey) async {
    final url = "$LIVE_API_PATH/payment_methods";
    final options = new RequestOptions(publishableApiKey: publishableKey);
    final params = {'customer': customerId, 'type': 'card'};
    return _getStripeResponse(RequestMethod.get, url, options, params: params);
  }

  Future<Map<String, dynamic>> createPaymentMethod(StripeCard card, String publishableKey) async {
    final url = "$LIVE_API_PATH/payment_methods";
    final options = new RequestOptions(publishableApiKey: publishableKey);
    final params = card.toPaymentMethod();
    final paymentMethod =
        await _getStripeResponse(RequestMethod.post, url, options, params: params);
    return paymentMethod;
  }

  Future<Map<String, dynamic>> attachPaymentMethod(
      String customerId, String paymentMethodId, String secretKey) async {
    final url = "$LIVE_API_PATH/payment_methods/$paymentMethodId/attach";
    final options = new RequestOptions(publishableApiKey: secretKey);
    final params = {'customer': customerId};
    return _getStripeResponse(RequestMethod.post, url, options, params: params);
  }

  Future<Map<String, dynamic>> detachPaymentMethod(
      String customerId, String paymentMethodId, String publishableKey) async {
    final url = "$LIVE_API_PATH/payment_methods/$paymentMethodId/detach";
    final options = new RequestOptions(publishableApiKey: publishableKey);
    return _getStripeResponse(RequestMethod.post, url, options);
  }

  ///
  ///
  ///
  Future<Customer> retrieveCustomer(String customerId, String secret) async {
    final String url = "$LIVE_API_PATH/customers/$customerId";
    final options = new RequestOptions(publishableApiKey: secret);
    final response = await _getStripeResponse(RequestMethod.get, url, options);
    final customer = Customer.fromJson(response);
    return customer;
  }

  ///
  ///
  ///
  Future<Source> addCustomerSource(String customerId, String sourceId, String secret) async {
    final String url = "$LIVE_API_PATH/customers/$customerId/sources";
    final options = new RequestOptions(publishableApiKey: secret);
    final response = await _getStripeResponse(
      RequestMethod.post,
      url,
      options,
      params: {FIELD_SOURCE: sourceId},
    );
    final source = Source.fromJson(response);
    return source;
  }

  ///
  ///
  ///
  Future<bool> deleteCustomerSource(String customerId, String sourceId, String secret) async {
    final String url = "$LIVE_API_PATH/customers/$customerId/sources/$sourceId";
    final options = new RequestOptions(publishableApiKey: secret);
    final response = await _getStripeResponse(
      RequestMethod.delete,
      url,
      options,
    );
    final bool deleted = response["deleted"];
    return deleted;
  }

  ///
  ///
  ///
  Future<Customer> updateCustomerDefaultSource(
      String customerId, String sourceId, String secret) async {
    final String url = "$LIVE_API_PATH/customers/$customerId";
    final options = new RequestOptions(publishableApiKey: secret);
    final response = await _getStripeResponse(
      RequestMethod.post,
      url,
      options,
      params: {"default_source": sourceId},
    );
    final customer = Customer.fromJson(response);
    return customer;
  }

  ///
  ///
  ///
  Future<Customer> updateCustomerShippingInformation(
      String customerId, ShippingInformation shippingInfo, String secret) async {
    final String url = "$LIVE_API_PATH/customers/$customerId";
    final options = new RequestOptions(publishableApiKey: secret);
    final response = await _getStripeResponse(
      RequestMethod.post,
      url,
      options,
      params: {"shipping": shippingInfo.toMap()},
    );
    final customer = Customer.fromJson(response);
    return customer;
  }

  ///
  ///
  ///
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
        throw new Exception("Request Method: $method not implemented");
    }

    final requestId = response.headers[HEADER_KEY_REQUEST_ID];

    final statusCode = response.statusCode;
    Map<String, dynamic> resp;
    try {
      resp = json.decode(response.body);
    } catch (error) {
      final stripeError =
          StripeAPIError(requestId, {StripeAPIError.FIELD_MESSAGE: MALFORMED_RESPONSE_MESSAGE});
      throw new StripeAPIException(stripeError);
    }

    if (statusCode < 200 || statusCode >= 300) {
      final Map<String, dynamic> errBody = resp[FIELD_ERROR];
      final stripeError = StripeAPIError(requestId, errBody);
      throw new StripeAPIException(stripeError);
    } else {
      return resp;
    }
  }

  ///
  ///
  ///
  static Map<String, String> _headers({RequestOptions options}) {
    final Map<String, String> headers = new Map();
    headers["Accept-Charset"] = CHARSET;
    headers["Accept"] = "application/json";
    headers["Content-Type"] = "application/x-www-form-urlencoded";
    headers["User-Agent"] = "Stripe/v1 DartBindings/$VERSION_NAME";

    if (options != null) {
      headers["Authorization"] = "Bearer ${options.publishableApiKey}";
    }

    // debug headers
    Map<String, String> propertyMap = new Map();
    propertyMap["os.name"] = defaultTargetPlatform.toString();
    //propertyMap["os.version"] = String.valueOf(Build.VERSION.SDK_INT));
    propertyMap["bindings.version"] = VERSION_NAME;
    propertyMap["lang"] = "Dart";
    propertyMap["publisher"] = "Vzotech";

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
        .map((key) => '${Uri.encodeComponent(key)}=${Uri.encodeComponent(params[key].toString())}')
        .join('&');
  }

  static String _urlEncodeMap(dynamic data) {
    StringBuffer urlData = new StringBuffer("");
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
  final String publishableApiKey;
  final String requestType;
  final String stripeAccount;

  RequestOptions({
    this.apiVersion = API_VERSION,
    this.guid,
    this.idempotencyKey,
    this.publishableApiKey,
    this.requestType,
    this.stripeAccount,
  });
}
