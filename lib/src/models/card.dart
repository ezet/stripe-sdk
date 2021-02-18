import 'package:credit_card_validator/credit_card_validator.dart';

class StripeCard {
  final _ccValidator = CreditCardValidator();

  String number;
  String cvc;
  int expMonth;
  int expYear;
  String last4;
  String postalCode;

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
  bool isPostalCodeValid() {
    return (postalCode != null && postalCode.isNotEmpty)
        ? int.tryParse(postalCode) != null
        : false;
  }

  /// Checks whether or not the {@link #number} field is valid.
  ///
  /// @return {@code true} if valid, {@code false} otherwise.
  bool validateNumber() {
    return number != null ? _ccValidator.validateCCNum(number).isValid : false;
  }

  /// Checks whether or not the {@link #expMonth} and {@link #expYear} fields represent a valid
  /// expiry date.
  ///
  /// @return {@code true} if valid, {@code false} otherwise
  bool validateDate() {
    return _ccValidator
        .validateExpDate(
        '${expMonth.toString().padLeft(2, '0')}/${expYear.toString().padLeft(2, '0')}')
        .isValid;
  }

  /// Checks whether or not the {@link #cvc} field is valid.
  ///
  /// @return {@code true} if valid, {@code false} otherwise
  bool validateCVC() {
    if (cvc == null) return false;
    return _ccValidator.validateCVV(cvc, cardType:_ccValidator.validateCCNum(number).ccType).isValid;
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
      'billing_details': {
        'address': {'postal_code': postalCode}
      }
    };
    _removeNullAndEmptyParams(map);
    return map;
  }

  static void _removeNullAndEmptyParams(Map<String, Object> mapToEdit) {
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
        _removeNullAndEmptyParams(value);
      }
    }
  }
}
