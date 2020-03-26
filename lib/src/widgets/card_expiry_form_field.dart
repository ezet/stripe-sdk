import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Form field to edit a credit card expiration date, with validation.
class CardExpiryFormField extends StatelessWidget {
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

  static const defaultLabelText = "Expiry Date";
  static const defaultHintText = "MM/YY";
  static const defaultErrorText = "Invalid expiry date";

  static const defaultDecoration = InputDecoration(
      border: OutlineInputBorder(),
      labelText: defaultLabelText,
      hintText: defaultHintText);
  static const defaultTextStyle = TextStyle(color: Colors.black);

    String _formatInitialValue() {
    String month = '';
    String year = '';

    if (initialMonth != null && initialYear != null) {
      if (initialMonth < 10) {
        month = '0' + initialMonth.toString();
      } else {
        month = initialMonth.toString();
      }

      final String initialYearString = initialYear.toString();

      year = initialYearString.substring(initialYearString.length - 2, initialYearString.length);
    }

    return '$month$year';
  }

  @override
  Widget build(BuildContext context) {
    var maskFormatter = MaskTextInputFormatter(mask: '##/##');

    return Container(
      child: TextFormField(
        validator: validator,
        initialValue: _formatInitialValue(),
        onChanged: (text) {
          final arr = text.split("/");
          final month = int.tryParse(arr[0]);
          final year = int.tryParse(arr[1]);
          onChanged(month, year);
        },
        onSaved: (text) {
          final arr = text.split("/");
          final month = int.tryParse(arr[0]);
          final year = int.tryParse(arr[1]);
          onSaved(month, year);
        },
        inputFormatters: [maskFormatter],
        style: textStyle,
        decoration: decoration,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
