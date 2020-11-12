import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Form field to edit a credit card expiration date, with validation.
class CardExpiryFormField extends StatefulWidget {
  const CardExpiryFormField(
      {Key key,
      this.initialMonth,
      this.initialYear,
      @required this.onSaved,
      @required this.validator,
      @required this.onChanged,
      this.decoration = defaultDecoration,
      this.textStyle = defaultTextStyle})
      : super(key: key);

  final int initialMonth;
  final int initialYear;
  final InputDecoration decoration;
  final TextStyle textStyle;
  final void Function(int, int) onSaved;
  final void Function(int, int) onChanged;
  final String Function(String) validator;

  static const defaultLabelText = 'Expiration Date';
  static const defaultHintText = 'MM/YY';
  static const defaultErrorText = 'Invalid expiration date';
  static const defaultMonthMask = '##';
  static const defaultYearMask = '##';

  static const defaultDecoration =
      InputDecoration(border: OutlineInputBorder(), labelText: defaultLabelText, hintText: defaultHintText);
  static const defaultTextStyle = TextStyle(color: Colors.black);

  @override
  _CardExpiryFormFieldState createState() => _CardExpiryFormFieldState();
}

class _CardExpiryFormFieldState extends State<CardExpiryFormField> {
  final maskFormatter =
      MaskTextInputFormatter(mask: '${CardExpiryFormField.defaultMonthMask}/${CardExpiryFormField.defaultYearMask}');

  @override
  Widget build(BuildContext context) {
    final month = widget.initialMonth?.toString()?.padLeft(CardExpiryFormField.defaultMonthMask.length, '0');
    final year = widget.initialYear?.toString()?.substring(widget.initialYear.toString().length -
        min(CardExpiryFormField.defaultYearMask.length, widget.initialYear.toString().length));
    final initial = (month ?? '') + (year ?? '');

    final initialMaskFormatter =
        MaskTextInputFormatter(mask: '${CardExpiryFormField.defaultMonthMask}/${CardExpiryFormField.defaultYearMask}');

    return TextFormField(
      validator: widget.validator,
      initialValue: initialMaskFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: initial)).text,
      autofillHints: [AutofillHints.creditCardExpirationDate],
      onChanged: (text) {
        final arr = text.split('/');
        final month = int.tryParse(arr[0]);
        var year;
        if (arr.length == 2) {
          year = int.tryParse(arr[1]);
        }
        widget.onChanged(month, year);
      },
      onSaved: (text) {
        final arr = text.split('/');
        final month = int.tryParse(arr[0]);
        final year = int.tryParse(arr[1]);
        widget.onSaved(month, year);
      },
      inputFormatters: [maskFormatter],
      style: widget.textStyle,
      decoration: widget.decoration,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
    );
  }
}
