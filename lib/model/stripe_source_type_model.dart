import 'stripe_json_model.dart';

abstract class StripeSourceTypeModel extends StripeJsonModel {
  Map<String, Object> additionalFields = new Map();
  Set<String> standardFields = new Set();
  static const String NULL = "null";

  void addStandardFields(List<String> fields) {
    standardFields.addAll(fields);
  }

  static void putAdditionalFieldsIntoMap(
      Map<String, Object> map, Map<String, Object> additionalFields) {
    if (map == null || additionalFields == null || additionalFields.isEmpty) {
      return;
    }

    for (String key in additionalFields.keys) {
      map[key] = additionalFields[key];
    }
  }
}
