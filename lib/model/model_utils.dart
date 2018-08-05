import '../text_utils.dart';

class ModelUtils {
  /**
   * Check to see whether the input string is a whole, positive number.
   *
   * @param value the input string to test
   * @return {@code true} if the input value consists entirely of integers
   */
  static bool isWholePositiveNumber(String value) {
    return value != null && isDigitsOnly(value);
  }

  /**
   * Determines whether the input year-month pair has passed.
   *
   * @param year the input year, as a two or four-digit integer
   * @param month the input month
   * @param now the current time
   * @return {@code true} if the input time has passed the specified current time,
   *  {@code false} otherwise.
   */
  static bool hasMonthPassed(int year, int month, DateTime now) {
    if (hasYearPassed(year, now)) {
      return true;
    }

    // Expires at end of specified month, Calendar month starts at 0
    return normalizeYear(year, now) == now.year && month < (now.month + 1);
  }

  /**
   * Determines whether or not the input year has already passed.
   *
   * @param year the input year, as a two or four-digit integer
   * @param now, the current time
   * @return {@code true} if the input year has passed the year of the specified current time
   *  {@code false} otherwise.
   */
  static bool hasYearPassed(int year, DateTime now) {
    int normalized = normalizeYear(year, now);
    return normalized < now.year;
  }

  static int normalizeYear(int year, DateTime now) {
    if (year < 100 && year >= 0) {
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix$year');
    }
    return year;
  }
}
