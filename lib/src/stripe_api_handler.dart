import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'stripe_error.dart';

const String DEFAULT_API_VERSION = '2020-03-02';

enum RequestMethod { get, post, put, delete, option }

class StripeApiHandler {
  static const String LIVE_API_BASE = 'https://api.stripe.com';
  static const String LIVE_LOGGING_BASE = 'https://q.stripe.com';
  static const String LOGGING_ENDPOINT = 'https://m.stripe.com/4';
  static const String LIVE_API_PATH = LIVE_API_BASE + '/v1';

  static const String CHARSET = 'UTF-8';
  static const String CUSTOMERS = 'customers';
  static const String TOKENS = 'tokens';
  static const String SOURCES = 'sources';

  static const String HEADER_KEY_REQUEST_ID = 'Request-Id';
  static const String FIELD_ERROR = 'error';
  static const String FIELD_SOURCE = 'source';

  String apiVersion = DEFAULT_API_VERSION;

  static const String MALFORMED_RESPONSE_MESSAGE = 'An improperly formatted error response was found.';

  final http.Client _client = http.Client();

  final String stripeAccount;

  StripeApiHandler({this.stripeAccount});

  Future<Map<String, dynamic>> request(RequestMethod method, String path, String key, String apiVersion,
      {final Map<String, dynamic> params}) {
    final options = RequestOptions(key: key, apiVersion: apiVersion, stripeAccount: stripeAccount);
    return _getStripeResponse(method, LIVE_API_PATH + path, options, params: params);
  }

  Future<Map<String, dynamic>> _getStripeResponse(RequestMethod method, final String url, final RequestOptions options,
      {final Map<String, dynamic> params}) async {
    final headers = _headers(options: options);

    http.Response response;

    switch (method) {
      case RequestMethod.get:
        var fUrl = url;
        if (params != null && params.isNotEmpty) {
          fUrl = '$url?${_encodeMap(params)}';
        }
        response = await _client.get(Uri.parse(fUrl), headers: headers);
        break;

      case RequestMethod.post:
        response = await _client.post(
          Uri.parse(url),
          headers: headers,
          body: params != null ? _urlEncodeMap(params) : null,
        );
        break;

      case RequestMethod.delete:
        response = await _client.delete(Uri.parse(url), headers: headers);
        break;
      default:
        throw Exception('Request Method: $method not implemented');
    }

    final requestId = response.headers[HEADER_KEY_REQUEST_ID];

    final statusCode = response.statusCode;
    Map<String, dynamic> resp;
    try {
      resp = json.decode(response.body);
    } catch (error) {
      final stripeError = StripeApiError(requestId, {StripeApiError.FIELD_MESSAGE: MALFORMED_RESPONSE_MESSAGE});
      throw StripeApiException(stripeError);
    }

    if (statusCode < 200 || statusCode >= 300) {
      final Map<String, dynamic> errBody = resp[FIELD_ERROR];
      final stripeError = StripeApiError(requestId, errBody);
      throw StripeApiException(stripeError);
    } else {
      return resp;
    }
  }

  ///
  ///
  ///
  static Map<String, String> _headers({RequestOptions options}) {
    final headers = <String, String>{};
    headers['Accept-Charset'] = CHARSET;
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    headers['User-Agent'] = 'StripeSDK/v2';

    if (options != null) {
      headers['Authorization'] = 'Bearer ${options.key}';
    }

    // debug headers
    final propertyMap = <String, String>{};
    propertyMap['os.name'] = defaultTargetPlatform.toString();
    propertyMap['lang'] = 'Dart';
    propertyMap['publisher'] = 'lars.dahl@gmail.com';

    headers['X-Stripe-Client-User-Agent'] = json.encode(propertyMap);

    if (options != null) {
      if (options.apiVersion != null) {
        headers['Stripe-Version'] = options.apiVersion;
      }

      if (options.stripeAccount != null) {
        headers['Stripe-Account'] = options.stripeAccount;
      }

      if (options.idempotencyKey != null) {
        headers['Idempotency-Key'] = options.idempotencyKey;
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
    final urlData = StringBuffer('');
    var first = true;
    void urlEncode(dynamic sub, String path) {
      if (sub is List) {
        for (var i = 0; i < sub.length; i++) {
          urlEncode(sub[i], '$path%5B%5D');
        }
      } else if (sub is Map) {
        sub.forEach((k, v) {
          if (path == '') {
            urlEncode(v, '${Uri.encodeQueryComponent(k)}');
          } else {
            urlEncode(v, '$path%5B${Uri.encodeQueryComponent(k)}%5D');
          }
        });
      } else {
        if (!first) {
          urlData.write('&');
        }
        first = false;
        urlData.write('$path=${Uri.encodeQueryComponent(sub.toString())}');
      }
    }

    urlEncode(data, '');
    return urlData.toString();
  }
}

class RequestOptions {
  static const String TYPE_QUERY = 'source';
  static const String TYPE_JSON = 'json_data';

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
