// @dart=2.9

const String NULL = 'null';

/// Calls through to {@link JSONObject#optString(String)} while safely
/// converting the raw string "null" and the empty string to {@code null}. Will not throw
/// an exception if the field isn't found.
///
/// @param jsonObject the input object
/// @param fieldName the optional field name
/// @return the value stored in the field, or {@code null} if the field isn't present
String optString(Map<String, dynamic> json, String fieldName) {
  return nullIfNullOrEmpty(json[fieldName] ?? '');
}

/// Calls through to {@link JSONObject#optInt(String)} only in the case that the
/// key exists. This returns {@code null} if the key is not in the object.
///
/// @param jsonObject the input object
/// @param fieldName the required field name
/// @return the value stored in the requested field, or {@code null} if the key is not present
bool optBoolean(Map<String, dynamic> json, String fieldName) {
  return json[fieldName];
}

/// Calls through to {@link JSONObject#optInt(String)} only in the case that the
/// key exists. This returns {@code null} if the key is not in the object.
///
/// @param jsonObject the input object
/// @param fieldName the required field name
/// @return the value stored in the requested field, or {@code null} if the key is not present
int optInteger(Map<String, dynamic> json, String fieldName) {
  return json[fieldName];
}

/// Calls through to {@link JSONObject#optString(String)} while safely converting
/// the raw string "null" and the empty string to {@code null}, along with any value that isn't
/// a two-character string.
/// @param jsonObject the object from which to retrieve the country code
/// @param fieldName the name of the field in which the country code is stored
/// @return a two-letter country code if one is found, or {@code null}
String optCountryCode(Map<String, dynamic> json, String fieldName) {
  final value = optString(json, fieldName);
  if (value != null && value.length == 2) {
    return value;
  }
  return null;
}

/// Calls through to {@link JSONObject#optString(String)} while safely converting
/// the raw string "null" and the empty string to {@code null}, along with any value that isn't
/// a three-character string.
/// @param jsonObject the object from which to retrieve the currency code
/// @param fieldName the name of the field in which the currency code is stored
/// @return a three-letter currency code if one is found, or {@code null}
String optCurrency(Map<String, dynamic> json, String fieldName) {
  final value = optString(json, fieldName);
  if (value != null && value.length == 3) {
    return value;
  }
  return null;
}

///
String nullIfNullOrEmpty(String possibleNull) {
  return ((NULL == possibleNull) || (possibleNull.isEmpty)) ? null : possibleNull;
}
