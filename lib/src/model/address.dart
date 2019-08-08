import '../model/stripe_json_model.dart';

class Address extends StripeJsonModel {
  static const String FIELD_CITY = "city";

  /* 2 Character Country Code */
  static const String FIELD_COUNTRY = "country";
  static const String FIELD_LINE_1 = "line1";
  static const String FIELD_LINE_2 = "line2";
  static const String FIELD_POSTAL_CODE = "postal_code";
  static const String FIELD_STATE = "state";

  String city;
  String country;
  String line1;
  String line2;
  String postalCode;
  String state;

  Address({
    this.city,
    this.country,
    this.line1,
    this.line2,
    this.postalCode,
    this.state,
  });

  Address.fromJson(Map<String, dynamic> json) {
    city = json[FIELD_CITY];
    country = json[FIELD_COUNTRY];
    line1 = json[FIELD_LINE_1];
    line2 = json[FIELD_LINE_2];
    postalCode = json[FIELD_POSTAL_CODE];
    state = json[FIELD_STATE];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> hashMap = new Map();
    hashMap[FIELD_CITY] = city;
    hashMap[FIELD_COUNTRY] = country;
    hashMap[FIELD_LINE_1] = line1;
    hashMap[FIELD_LINE_2] = line2;
    hashMap[FIELD_POSTAL_CODE] = postalCode;
    hashMap[FIELD_STATE] = state;
    return hashMap;
  }
}
