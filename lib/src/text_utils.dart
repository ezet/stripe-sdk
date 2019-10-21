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
