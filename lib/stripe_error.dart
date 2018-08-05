import 'model/stripe_json_utils.dart';

class StripeAPIError {
  static const String FIELD_TYPE = "type";
  static const String FIELD_CHARGE = "charge";
  static const String FIELD_CODE = "code";
  static const String FIELD_DECLINE_CODE = "decline_code";
  static const String FIELD_DOC_URL = "doc_url";
  static const String FIELD_MESSAGE = "message";
  static const String FIELD_PARAM = "param";

  final String requestId;
  final String type;
  final String charge;
  final String code;
  final String declineCode;
  final String docUrl;
  final String message;
  final String param;

  StripeAPIError._internal(
    this.requestId,
    this.type,
    this.charge,
    this.code,
    this.declineCode,
    this.docUrl,
    this.message,
    this.param,
  );

  factory StripeAPIError(String requestId, Map<String, dynamic> json) {
    final type = optString(json, FIELD_TYPE);
    final charge = optString(json, FIELD_CHARGE);
    final code = optString(json, FIELD_CODE);
    final declineCode = optString(json, FIELD_DECLINE_CODE);
    final docUrl = optString(json, FIELD_DOC_URL);
    final message = optString(json, FIELD_MESSAGE);
    final param = optString(json, FIELD_PARAM);

    return new StripeAPIError._internal(
      requestId,
      type,
      charge,
      code,
      declineCode,
      docUrl,
      message,
      param,
    );
  }
}

class StripeAPIException implements Exception {
  final StripeAPIError error;
  final String requestId;
  final String message;

  StripeAPIException(this.error)
      : requestId = error.requestId,
        message = error.message;

  @override
  String toString() {
    return message;
  }
}
