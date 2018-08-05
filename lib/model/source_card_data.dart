import 'stripe_source_type_model.dart';
import '../stripe_network_utils.dart';

class SourceCardData extends StripeSourceTypeModel {
  static const String REQUIRED = "required";
  static const String OPTIONAL = "optional";
  static const String NOT_SUPPORTED = "not_supported";
  static const String UNKNOWN = "unknown";

  static const String FIELD_ADDRESS_LINE1_CHECK = "address_line1_check";
  static const String FIELD_ADDRESS_ZIP_CHECK = "address_zip_check";
  static const String FIELD_BRAND = "brand";
  static const String FIELD_COUNTRY = "country";
  static const String FIELD_CVC_CHECK = "cvc_check";
  static const String FIELD_DYNAMIC_LAST4 = "dynamic_last4";
  static const String FIELD_EXP_MONTH = "exp_month";
  static const String FIELD_EXP_YEAR = "exp_year";
  static const String FIELD_FUNDING = "funding";
  static const String FIELD_LAST4 = "last4";
  static const String FIELD_THREE_D_SECURE = "three_d_secure";
  static const String FIELD_TOKENIZATION_METHOD = "tokenization_method";

  String addressLine1Check;
  String addressZipCheck;
  String brand;
  String country;
  String cvcCheck;
  String dynamicLast4;
  int expiryMonth;
  int expiryYear;
  String funding;
  String last4;
  String threeDSecureStatus;
  String tokenizationMethod;

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> objectMap = new Map();
    objectMap[FIELD_ADDRESS_LINE1_CHECK] = addressLine1Check;
    objectMap[FIELD_ADDRESS_ZIP_CHECK] = addressZipCheck;
    objectMap[FIELD_BRAND] = brand;
    objectMap[FIELD_COUNTRY] = country;
    objectMap[FIELD_DYNAMIC_LAST4] = dynamicLast4;
    objectMap[FIELD_EXP_MONTH] = expiryMonth;
    objectMap[FIELD_EXP_YEAR] = expiryYear;
    objectMap[FIELD_FUNDING] = funding;
    objectMap[FIELD_LAST4] = last4;
    objectMap[FIELD_THREE_D_SECURE] = threeDSecureStatus;
    objectMap[FIELD_TOKENIZATION_METHOD] = tokenizationMethod;

    StripeSourceTypeModel.putAdditionalFieldsIntoMap(
        objectMap, additionalFields);
    removeNullAndEmptyParams(objectMap);
    return objectMap;
  }
}
