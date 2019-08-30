import 'package:stripe_sdk/src/stripe_network_utils.dart';

import 'customer_source.dart';
import 'shipping_information.dart';
import 'stripe_json_model.dart';
import 'stripe_json_utils.dart';

class Customer extends StripeJsonModel {
  static const String FIELD_ID = "id";
  static const String FIELD_OBJECT = "object";
  static const String FIELD_DEFAULT_SOURCE = "default_source";
  static const String FIELD_SHIPPING = "shipping";
  static const String FIELD_SOURCES = "sources";

  static const String FIELD_DATA = "data";
  static const String FIELD_HAS_MORE = "has_more";
  static const String FIELD_TOTAL_COUNT = "total_count";
  static const String FIELD_URL = "url";

  static const String VALUE_LIST = "list";
  static const String VALUE_CUSTOMER = "customer";

  static const String VALUE_APPLE_PAY = "apple_pay";

  String id;

  String defaultSource;
  ShippingInformation shippingInformation;

  List<CustomerSource> sources = [];
  bool hasMore;
  int totalCount;
  String url;

  Customer.fromJson(Map<String, dynamic> json) {
    id = optString(json, FIELD_ID);
    defaultSource = optString(json, FIELD_DEFAULT_SOURCE);
    final shipInfoObject = json[FIELD_SHIPPING]; //.cast<String, dynamic>()
    if (shipInfoObject != null) {
      shippingInformation =
          new ShippingInformation.fromJson(shipInfoObject.cast<String, dynamic>());
    }

    final Map<String, dynamic> sources = json[FIELD_SOURCES].cast<String, dynamic>();
    if (sources != null && (VALUE_LIST == optString(sources, FIELD_OBJECT))) {
      hasMore = optBoolean(sources, FIELD_HAS_MORE);
      totalCount = optInteger(sources, FIELD_TOTAL_COUNT);
      url = optString(sources, FIELD_URL);

      List<CustomerSource> sourceDataList = new List();
      List dataArray = sources[FIELD_DATA] ?? new List();
      for (int i = 0; i < dataArray.length; i++) {
        try {
          var customerSourceObject = dataArray[i];
          CustomerSource sourceData =
              new CustomerSource.fromJson(customerSourceObject.cast<String, dynamic>());
          if (sourceData == null || VALUE_APPLE_PAY == sourceData.getTokenizationMethod()) {
            continue;
          }
          sourceDataList.add(sourceData);
        } catch (ignored) {
          print(ignored);
        }
      }
      this.sources = sourceDataList;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> mapObject = new Map();
    mapObject[FIELD_ID] = id;
    mapObject[FIELD_OBJECT] = VALUE_CUSTOMER;
    mapObject[FIELD_DEFAULT_SOURCE] = defaultSource;

    StripeJsonModel.putStripeJsonModelMapIfNotNull(mapObject, FIELD_SHIPPING, shippingInformation);

    Map<String, Object> sourcesObject = new Map();
    sourcesObject[FIELD_HAS_MORE] = hasMore;
    sourcesObject[FIELD_TOTAL_COUNT] = totalCount;
    sourcesObject[FIELD_OBJECT] = VALUE_LIST;
    sourcesObject[FIELD_URL] = url;
    StripeJsonModel.putStripeJsonModelListIfNotNull(sourcesObject, FIELD_DATA, sources);
    removeNullAndEmptyParams(sourcesObject);

    mapObject[FIELD_SOURCES] = sourcesObject;

    removeNullAndEmptyParams(mapObject);
    return mapObject;
  }
}
