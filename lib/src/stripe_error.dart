import 'util/stripe_json_utils.dart';

class StripeApiError {
  static const String fieldType = 'type';
  static const String fieldCharge = 'charge';
  static const String fieldCode = 'code';
  static const String fieldDeclineCode = 'decline_code';
  static const String fieldDocUrl = 'doc_url';
  static const String fieldMessage = 'message';
  static const String fieldParam = 'param';

  final String? requestId;
  final String? type;
  final String? charge;
  final String? code;
  final String? declineCode;
  final String? docUrl;
  final String? message;
  final String? param;

  StripeApiError._internal(
    this.requestId,
    this.type,
    this.charge,
    this.code,
    this.declineCode,
    this.docUrl,
    this.message,
    this.param,
  );

  factory StripeApiError(String? requestId, Map<String, dynamic> json) {
    final type = optString(json, fieldType);
    final charge = optString(json, fieldCharge);
    final code = optString(json, fieldCode);
    final declineCode = optString(json, fieldDeclineCode);
    final docUrl = optString(json, fieldDocUrl);
    final message = optString(json, fieldMessage);
    final param = optString(json, fieldParam);

    return StripeApiError._internal(
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

class StripeApiException implements Exception {
  final StripeApiError error;
  final String? requestId;
  final String message;

  StripeApiException(this.error)
      : requestId = error.requestId,
        message = error.message!;

  @override
  String toString() {
    return message;
  }
}
