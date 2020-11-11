/// Util Array for converting bytes to a hex string.
/// {@url http://stackoverflow.com/questions/9655181/convert-from-byte-array-to-hex-string-in-java}
const String HEX_ARRAY = '0123456789ABCDEF';

///Swap {@code null} for blank text values.
///
/// @param value an input string that may or may not be entirely whitespace
/// @return {@code null} if the string is entirely whitespace, otherwise the input value
///
String nullIfBlank(String value) {
  if (isBlank(value)) {
    return null;
  }
  return value;
}

/// A checker for whether or not the input value is entirely whitespace. This is slightly more
/// aggressive than the android TextUtils#isEmpty method, which only returns true for
/// {@code null} or {@code ""}.
///
/// @param value a possibly blank input string value
/// @return {@code true} if and only if the value is all whitespace, {@code null}, or empty
bool isBlank(String value) {
  return value == null || value.trim().isEmpty;
}

/// Converts a card number that may have spaces between the numbers into one without any spaces.
/// Note: method does not check that all characters are digits or spaces.
///
/// @param cardNumberWithSpaces a card number, for instance "4242 4242 4242 4242"
/// @return the input number minus any spaces, for instance "4242424242424242".
/// Returns {@code null} if the input was {@code null} or all spaces.
String removeSpacesAndHyphens(String cardNumberWithSpaces) {
  if (isBlank(cardNumberWithSpaces)) {
    return null;
  }
  return cardNumberWithSpaces.replaceAll(RegExp(r'\s+|\-+'), '');
}

/// Check to see if the input number has any of the given prefixes.
///
/// @param number the number to test
/// @param prefixes the prefixes to test against
/// @return {@code true} if number begins with any of the input prefixes
bool hasAnyPrefix(String number, List<String> prefixes) {
  if (number == null) {
    return false;
  }

  for (var prefix in prefixes) {
    if (number.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}

bool isDigit(String s) {
  if (s == null) {
    return false;
  }
  return int.tryParse(s) != null;
}

bool isDigitsOnly(String s) {
  if (s == null) {
    return false;
  }
  return int.tryParse(s) != null;
}

int getNumericValue(String s) {
  return int.tryParse(s);
}
