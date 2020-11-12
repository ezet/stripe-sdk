import 'package:credit_card_validator/credit_card_validator.dart';

class StripeCard {
  final _ccValidator = CreditCardValidator();

  static const String AMERICAN_EXPRESS = 'American Express';
  static const String DISCOVER = 'Discover';
  static const String JCB = 'JCB';
  static const String DINERS_CLUB = 'Diners Club';
  static const String VISA = 'Visa';
  static const String MASTERCARD = 'MasterCard';
  static const String UNIONPAY = 'UnionPay';
  static const String UNKNOWN = 'Unknown';

  ///
  // Based on http://en.wikipedia.org/wiki/Bank_card_number#Issuer_identification_number_.28IIN.29
  static const List<String> PREFIXES_AMERICAN_EXPRESS = ['34', '37'];
  static const List<String> PREFIXES_DISCOVER = ['60', '64', '65'];
  static const List<String> PREFIXES_JCB = ['35'];
  static const List<String> PREFIXES_DINERS_CLUB = ['300', '301', '302', '303', '304', '305', '309', '36', '38', '39'];
  static const List<String> PREFIXES_VISA = ['4'];
  static const List<String> PREFIXES_MASTERCARD = [
    '2221',
    '2222',
    '2223',
    '2224',
    '2225',
    '2226',
    '2227',
    '2228',
    '2229',
    '223',
    '224',
    '225',
    '226',
    '227',
    '228',
    '229',
    '23',
    '24',
    '25',
    '26',
    '270',
    '271',
    '2720',
    '50',
    '51',
    '52',
    '53',
    '54',
    '55',
    '67'
  ];
  static const List<String> PREFIXES_UNIONPAY = ['62'];

  static const int MAX_LENGTH_STANDARD = 16;
  static const int MAX_LENGTH_AMERICAN_EXPRESS = 15;
  static const int MAX_LENGTH_DINERS_CLUB = 14;

  String number;
  String cvc;
  int expMonth;
  int expYear;
  String last4;
  String _brand;

  StripeCard({
    this.number,
    this.cvc,
    this.expMonth,
    this.expYear,
    this.last4,
  });

  /// Checks whether or not the {@link #number} field is valid.
  ///
  /// @return {@code true} if valid, {@code false} otherwise.
  bool validateNumber() {
    return _ccValidator.validateCCNum(number).isValid;
  }

  /// Checks whether or not the {@link #expMonth} and {@link #expYear} fields represent a valid
  /// expiry date.
  ///
  /// @return {@code true} if valid, {@code false} otherwise
  bool validateDate() {
    return _ccValidator.validateExpDate('$expMonth/$expYear').isValid;
  }

  /// Checks whether or not the {@link #cvc} field is valid.
  ///
  /// @return {@code true} if valid, {@code false} otherwise
  bool validateCVC() {
    if (cvc == null) return false;
    final cardType = _ccValidator.validateCCNum(number).ccType;
    return _ccValidator.validateCVV(cvc, cardType: cardType).isValid;
  }

  /// Returns a stripe hash that represents this card.
  /// It only sets the type and card details. In order to add additional details such as name and address,
  /// you need to insert these keys into the hash before submitting it.
  Map<String, dynamic> toPaymentMethod() {
    final map = <String, dynamic>{
      'type': 'card',
      'card': {
        'number': number,
        'cvc': cvc,
        'exp_month': expMonth,
        'exp_year': expYear,
      },
    };
    removeNullAndEmptyParams(map);
    return map;
  }

  /// Converts an unchecked String value to a {@link CardBrand} or {@code null}.
  ///
  /// @param possibleCardType a String that might match a {@link CardBrand} or be empty.
  /// @return {@code null} if the input is blank, else the appropriate {@link CardBrand}.
  static String asCardBrand(String possibleCardType) {
    if (possibleCardType == null || possibleCardType.trim().isEmpty) {
      return null;
    }

    if (StripeCard.AMERICAN_EXPRESS == possibleCardType) {
      return StripeCard.AMERICAN_EXPRESS;
    } else if (StripeCard.MASTERCARD == possibleCardType) {
      return StripeCard.MASTERCARD;
    } else if (StripeCard.DINERS_CLUB == possibleCardType) {
      return StripeCard.DINERS_CLUB;
    } else if (StripeCard.DISCOVER == possibleCardType) {
      return StripeCard.DISCOVER;
    } else if (StripeCard.JCB == possibleCardType) {
      return StripeCard.JCB;
    } else if (StripeCard.VISA == possibleCardType) {
      return StripeCard.VISA;
    } else if (StripeCard.UNIONPAY == possibleCardType) {
      return StripeCard.UNIONPAY;
    } else {
      return StripeCard.UNKNOWN;
    }
  }

  static void removeNullAndEmptyParams(Map<String, Object> mapToEdit) {
    // Remove all null values; they cause validation errors
    final keys = mapToEdit.keys.toList(growable: false);
    for (var key in keys) {
      final value = mapToEdit[key];
      if (value == null) {
        mapToEdit.remove(key);
      } else if (value is String) {
        if (value.isEmpty) {
          mapToEdit.remove(key);
        }
      } else if (value is Map) {
        removeNullAndEmptyParams(value);
      }
    }
  }
}
