import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stripe_api/src/card_utils.dart';
import 'model/card.dart';
import 'package:stripe_api/src/stripe_text_utils.dart';

class CardNumberFormatter extends TextInputFormatter {
  final ValueChanged<String> onCardBrandChanged;
  final VoidCallback onCardNumberComplete;
  final ValueChanged<bool> onShowError;

  String _cardBrand;
  int _lengthMax = 19;
  bool _isCardNumberValid = false;

  CardNumberFormatter({
    this.onCardBrandChanged,
    this.onCardNumberComplete,
    this.onShowError,
  }) {
    _cardBrand = StripeCard.UNKNOWN;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    if (newValue.text.length < 4) {
      _updateCardBrandFromNumber(newValue.text);
    }

    String spacelessNumber = removeSpacesAndHyphens(newValue.text);
    if (spacelessNumber == null) {
      return newValue;
    }

    List<String> cardParts = separateCardNumberGroups(spacelessNumber, _cardBrand);
    String formattedNumber = '';
    for (int i = 0; i < cardParts.length; i++) {
      if (cardParts[i] == null) {
        break;
      }

      if (i != 0) {
        formattedNumber += ' ';
      }

      formattedNumber += cardParts[i];
    }

    TextSelection selection;
    if (newValue.selection.start >= formattedNumber.length - 1) {
      selection = TextSelection.fromPosition(TextPosition(offset: formattedNumber.length));
    } else {
      selection = newValue.selection;
    }

    final computedValue = newValue.copyWith(
      text: formattedNumber,
      composing: TextRange.empty,
      selection: selection,
    );

    if (computedValue.text.length == _lengthMax) {
      var before = _isCardNumberValid;
      _isCardNumberValid = isValidCardNumber(computedValue.text);
      if (onShowError != null) {
        onShowError(!_isCardNumberValid);
      }
      if (!before && _isCardNumberValid && onCardNumberComplete != null) {
        onCardNumberComplete();
      }
    } else {
      _isCardNumberValid = computedValue.text != null && isValidCardNumber(computedValue.text);
      // Don't show errors if we aren't full-length.
      if (onShowError != null) {
        onShowError(false);
      }
    }

    return computedValue;
  }

  void _updateCardBrand(String brand) {
    if (_cardBrand == brand) {
      return;
    }

    _cardBrand = brand;

    if (onCardBrandChanged != null) {
      onCardBrandChanged(brand);
    }

    _lengthMax = getLengthForBrand(brand);
  }

  void _updateCardBrandFromNumber(String partialNumber) {
    _updateCardBrand(getPossibleCardType(partialNumber));
  }
}

/// Separates a card number according to the brand requirements, including prefixes of card numbers, so that the groups can be easily displayed if the user is typing them in.
/// Note that this does not verify that the card number is valid, or even that it is a number.
///
///  * [spacelessCardNumber], the raw card number, without spaces
///  * [brand], to use as a separating scheme
///  Returns an array of strings with the number groups, in order. If the number is not complete, some of the array entries may be `null`
List<String> separateCardNumberGroups(
  String spacelessCardNumber,
  String brand,
) {
  //
  if (spacelessCardNumber.length > 16) {
    spacelessCardNumber = spacelessCardNumber.substring(0, 16);
  }
  //
  List<String> numberGroups;
  //
  if (brand == StripeCard.AMERICAN_EXPRESS) {
    numberGroups = new List(3);

    int length = spacelessCardNumber.length;
    int lastUsedIndex = 0;
    if (length > 4) {
      numberGroups[0] = spacelessCardNumber.substring(0, 4);
      lastUsedIndex = 4;
    }

    if (length > 10) {
      numberGroups[1] = spacelessCardNumber.substring(4, 10);
      lastUsedIndex = 10;
    }

    for (int i = 0; i < 3; i++) {
      if (numberGroups[i] != null) {
        continue;
      }
      numberGroups[i] = spacelessCardNumber.substring(lastUsedIndex);
      break;
    }
  } else {
    numberGroups = List(4);
    int i = 0;
    int previousStart = 0;
    while ((i + 1) * 4 < spacelessCardNumber.length) {
      String group = spacelessCardNumber.substring(previousStart, (i + 1) * 4);
      numberGroups[i] = group;
      previousStart = (i + 1) * 4;
      i++;
    }
    // Always stuff whatever is left into the next available array entry. This handles
    // incomplete numbers, full 16-digit numbers, and full 14-digit numbers
    numberGroups[i] = spacelessCardNumber.substring(previousStart);
  }
  return numberGroups;
}
