import 'package:stripe_sdk/src/stripe_network_utils.dart';

import 'address.dart';
import 'stripe_json_model.dart';
import 'stripe_json_utils.dart';

class ShippingInformation extends StripeJsonModel {
  static const String FIELD_ADDRESS = "address";
  static const String FIELD_NAME = "name";
  static const String FIELD_PHONE = "phone";

  Address address;
  String name;
  String phone;

  ShippingInformation({
    this.address,
    this.name,
    this.phone,
  });

  ShippingInformation.fromJson(Map<String, dynamic> json) {
    name = optString(json, FIELD_NAME);
    phone = optString(json, FIELD_PHONE);
    var addr = json[FIELD_ADDRESS];
    address = addr == null ? null : new Address.fromJson(addr.cast<String, dynamic>());
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> map = new Map();
    map[FIELD_NAME] = name;
    map[FIELD_PHONE] = phone;
    StripeJsonModel.putStripeJsonModelMapIfNotNull(map, FIELD_ADDRESS, address);
    removeNullAndEmptyParams(map);
    return map;
  }
}
