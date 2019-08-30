import 'package:stripe_sdk/src/stripe_network_utils.dart';

import 'stripe_json_model.dart';

class SourceRedirect extends StripeJsonModel {
  static const String PENDING = "pending";
  static const String SUCCEEDED = "succeeded";
  static const String FAILED = "failed";

  static const String FIELD_RETURN_URL = "return_url";
  static const String FIELD_STATUS = "status";
  static const String FIELD_URL = "url";

  String returnUrl;
  String status;
  String url;

  SourceRedirect({
    this.returnUrl,
    this.status,
    this.url,
  });

  SourceRedirect.fromJson(Map<String, dynamic> json) {
    returnUrl = json[FIELD_RETURN_URL];
    status = json[FIELD_STATUS];
    url = json[FIELD_URL];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> hashMap = new Map();
    hashMap[FIELD_RETURN_URL] = returnUrl;
    hashMap[FIELD_STATUS] = status;
    hashMap[FIELD_URL] = url;
    removeNullAndEmptyParams(hashMap);
    return hashMap;
  }
}
