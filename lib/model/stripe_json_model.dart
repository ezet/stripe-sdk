import 'dart:convert';

abstract class StripeJsonModel {
  Map<String, dynamic> toMap();

  String toJsonString() {
    return json.encode(toMap());
  }

  @override
  String toString() {
    return toJsonString();
  }

  static void putStripeJsonModelMapIfNotNull(Map<String, dynamic> upperLevelMap,
      String key, StripeJsonModel jsonModel) {
    if (jsonModel == null) {
      return;
    }
    upperLevelMap[key] = jsonModel.toMap();
  }

  static void putStripeJsonModelListIfNotNull(Map<String, Object> upperLevelMap,
      String key, List<StripeJsonModel> jsonModelList) {
    if (jsonModelList == null) {
      return;
    }

    List<Map<String, Object>> mapList = new List();
    for (int i = 0; i < jsonModelList.length; i++) {
      mapList.add(jsonModelList[i].toMap());
    }
    upperLevelMap[key] = mapList;
  }
}
