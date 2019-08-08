import 'address.dart';
import 'stripe_json_model.dart';
import 'stripe_json_utils.dart';
import 'package:stripe_api/src/stripe_network_utils.dart';

class SourceOwner extends StripeJsonModel {
  static const String VERIFIED = "verified_";
  static const String FIELD_ADDRESS = "address";
  static const String FIELD_EMAIL = "email";
  static const String FIELD_NAME = "name";
  static const String FIELD_PHONE = "phone";
  static const String FIELD_VERIFIED_ADDRESS = VERIFIED + FIELD_ADDRESS;
  static const String FIELD_VERIFIED_EMAIL = VERIFIED + FIELD_EMAIL;
  static const String FIELD_VERIFIED_NAME = VERIFIED + FIELD_NAME;
  static const String FIELD_VERIFIED_PHONE = VERIFIED + FIELD_PHONE;

  Address address;
  String email;
  String name;
  String phone;
  Address verifiedAddress;
  String verifiedEmail;
  String verifiedName;
  String verifiedPhone;

  SourceOwner({
    this.address,
    this.email,
    this.name,
    this.phone,
    this.verifiedAddress,
    this.verifiedEmail,
    this.verifiedName,
    this.verifiedPhone,
  });

  SourceOwner.fromJson(Map<String, dynamic> json) {
    var addressObject = json[FIELD_ADDRESS];
    if (addressObject != null) {
      address = Address.fromJson(addressObject);
    }

    email = optString(json, FIELD_EMAIL);
    name = optString(json, FIELD_NAME);
    phone = optString(json, FIELD_PHONE);

    var vAddressObject = json[FIELD_VERIFIED_ADDRESS];
    if (vAddressObject != null) {
      verifiedAddress = Address.fromJson(vAddressObject);
    }
    verifiedEmail = optString(json, FIELD_VERIFIED_EMAIL);
    verifiedName = optString(json, FIELD_VERIFIED_NAME);
    verifiedPhone = optString(json, FIELD_VERIFIED_PHONE);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> hashMap = new Map();
    if (address != null) {
      hashMap[FIELD_ADDRESS] = address.toMap();
    }
    hashMap[FIELD_EMAIL] = email;
    hashMap[FIELD_NAME] = name;
    hashMap[FIELD_PHONE] = phone;
    if (verifiedAddress != null) {
      hashMap[FIELD_VERIFIED_ADDRESS] = verifiedAddress.toMap();
    }
    hashMap[FIELD_VERIFIED_EMAIL] = verifiedEmail;
    hashMap[FIELD_VERIFIED_NAME] = verifiedName;
    hashMap[FIELD_VERIFIED_PHONE] = verifiedPhone;
    removeNullAndEmptyParams(hashMap);
    return hashMap;
  }
}
