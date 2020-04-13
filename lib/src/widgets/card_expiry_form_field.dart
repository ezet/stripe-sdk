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
  static const defaultMonthMask = "##";
  static const defaultYearMask = "##";

  static const defaultDecoration = InputDecoration(
      border: OutlineInputBorder(),
      labelText: defaultLabelText,
      hintText: defaultHintText);
  static const defaultTextStyle = TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    var maskFormatter =
        MaskTextInputFormatter(mask: '$defaultMonthMask/$defaultYearMask');

    final month =
        initialMonth?.toString()?.padLeft(defaultMonthMask.length, "0");
    final year = initialYear
        ?.toString()
        ?.substring(initialYear.toString().length - defaultYearMask.length);
    final initial = (month ?? "") + (year ?? "");

    return Container(
      child: TextFormField(
        validator: validator,
        initialValue: maskFormatter
            .formatEditUpdate(
                TextEditingValue(), TextEditingValue(text: initial))
            .text,
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
        onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
      ),
    );
  }
}
