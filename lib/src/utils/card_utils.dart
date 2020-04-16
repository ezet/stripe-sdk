import '../model/model_utils.dart';

bool validateExpiryDate(int month, int year) {
  final now = DateTime.now();
  if (!validateExpMonth(month)) {
    return false;
  }
  if (!validateExpYear(year)) {
    return false;
  }
  return !ModelUtils.hasMonthPassed(year, month, now);
}

/// Checks whether or not the {@link #expMonth} field is valid.
///
/// @return {@code true} if valid, {@code false} otherwise.
bool validateExpMonth(int month) {
  return month != null && month >= 1 && month <= 12;
}

/// Checks whether or not the {@link #expYear} field is valid.
///
/// @return {@code true} if valid, {@code false} otherwise.
bool validateExpYear(int year) {
  final now = DateTime.now();
  return year != null && !ModelUtils.hasYearPassed(year, now);
}
