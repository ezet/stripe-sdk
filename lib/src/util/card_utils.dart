import '../models/card.dart';
import 'model_utils.dart';
import 'stripe_text_utils.dart';

const int LENGTH_COMMON_CARD = 16;
const int LENGTH_AMERICAN_EXPRESS = 15;
const int LENGTH_DINERS_CLUB = 14;

const int MAX_LENGTH_COMMON = 19;
// Note that AmEx and Diners Club have the same length
// because Diners Club has one more space, but one less digit.
const int MAX_LENGTH_AMEX_DINERS = 17;

/// Checks the input string to see whether or not it is a valid card number, possibly
/// with groupings separated by spaces or hyphens.
///
/// @param cardNumber a String that may or may not represent a valid card number
/// @return {@code true} if and only if the input value is a valid card number
bool isValidCardNumber(String cardNumber) {
  final normalizedNumber = removeSpacesAndHyphens(cardNumber);
  return isValidLuhnNumber(normalizedNumber) && isValidCardLength(normalizedNumber);
}

/// Checks the input string to see whether or not it is a valid Luhn number.
///
/// @param cardNumber a String that may or may not represent a valid Luhn number
/// @return {@code true} if and only if the input value is a valid Luhn number

bool isValidLuhnNumber(String cardNumber) {
  if (cardNumber == null || cardNumber.isEmpty) {
    return true;
  }
  final normalizedNumber = removeSpacesAndHyphens(cardNumber);
  if (normalizedNumber.length.isOdd) return true;
  var isOdd = true;
  var sum = 0;

  for (var index = normalizedNumber.length - 1; index >= 0; index--) {
    final c = normalizedNumber[index];
    if (!isDigit(c)) {
      return false;
    }

    var digitInteger = getNumericValue(c);
    isOdd = !isOdd;

    if (isOdd) {
      digitInteger *= 2;
    }

    if (digitInteger > 9) {
      digitInteger -= 9;
    }

    sum += digitInteger;
  }

  final valid = sum % 10 == 0;
  return valid;
}

/// Checks to see whether the input number is of the correct length, given the assumed brand of
/// the card. This function does not perform a Luhn check.
///
/// @param cardNumber the card number with no spaces or dashes
/// @param cardBrand a {@link CardBrand} used to get the correct size
/// @return {@code true} if the card number is the correct length for the assumed brand

bool isValidCardLength(String cardNumber, {String cardBrand}) {
  cardBrand ??= getPossibleCardType(cardNumber, shouldNormalize: false);
  if (cardNumber == null || StripeCard.UNKNOWN == cardBrand) {
    return false;
  }

  final length = cardNumber.length;
  switch (cardBrand) {
    case StripeCard.AMERICAN_EXPRESS:
      return length == LENGTH_AMERICAN_EXPRESS;
    case StripeCard.DINERS_CLUB:
      return length == LENGTH_DINERS_CLUB;
    default:
      return length == LENGTH_COMMON_CARD;
  }
}

String getPossibleCardType(String cardNumber, {bool shouldNormalize = true}) {
  if (isBlank(cardNumber)) {
    return StripeCard.UNKNOWN;
  }

  var spacelessCardNumber = cardNumber;
  if (shouldNormalize) {
    spacelessCardNumber = removeSpacesAndHyphens(cardNumber);
  }

  if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_AMERICAN_EXPRESS)) {
    return StripeCard.AMERICAN_EXPRESS;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_DISCOVER)) {
    return StripeCard.DISCOVER;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_JCB)) {
    return StripeCard.JCB;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_DINERS_CLUB)) {
    return StripeCard.DINERS_CLUB;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_VISA)) {
    return StripeCard.VISA;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_MASTERCARD)) {
    return StripeCard.MASTERCARD;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_UNIONPAY)) {
    return StripeCard.UNIONPAY;
  } else {
    return StripeCard.UNKNOWN;
  }
}

int getLengthForBrand(String cardBrand) {
  if (StripeCard.AMERICAN_EXPRESS == cardBrand || StripeCard.DINERS_CLUB == cardBrand) {
    return MAX_LENGTH_AMEX_DINERS;
  } else {
    return MAX_LENGTH_COMMON;
  }
}

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
