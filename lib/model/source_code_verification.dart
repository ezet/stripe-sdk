import 'stripe_json_model.dart';

class SourceCodeVerification extends StripeJsonModel {
  static const String PENDING = "pending";
  static const String SUCCEEDED = "succeeded";
  static const String FAILED = "failed";

  static const String FIELD_ATTEMPTS_REMAINING = "attempts_remaining";
  static const String FIELD_STATUS = "status";
  static const int INVALID_ATTEMPTS_REMAINING = -1;

  int attemptsRemaining;
  String status;

  SourceCodeVerification(this.attemptsRemaining, this.status);

  SourceCodeVerification.fromJson(Map<String, dynamic> json) {
    attemptsRemaining =
        json['FIELD_ATTEMPTS_REMAINING'] ?? INVALID_ATTEMPTS_REMAINING;
    status = _asStatus(json['FIELD_STATUS']);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> hashMap = new Map();
    hashMap[FIELD_ATTEMPTS_REMAINING] = attemptsRemaining;
    if (status != null) {
      hashMap[FIELD_STATUS] = status;
    }
    return hashMap;
  }

  static String _asStatus(String stringStatus) {
    if (stringStatus == null) {
      return null;
    } else if (PENDING == stringStatus) {
      return PENDING;
    } else if (SUCCEEDED == stringStatus) {
      return SUCCEEDED;
    } else if (FAILED == stringStatus) {
      return FAILED;
    }

    return null;
  }
}
