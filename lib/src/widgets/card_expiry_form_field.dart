import 'package:flutter/material.dart';

import 'masked_text_controller.dart';

/// Form field to edit a credit card expiration date, with validation.
class CardExpiryFormField extends StatelessWidget {
  const CardExpiryFormField({
    Key key,
    this.initialMonth,
    this.initialYear,
    @required this.onSaved,
    @required this.validator,
    @required this.onChanged,
    this.decoration = defaultDecoration,
  }) : super(key: key);

  final int initialMonth;
  final int initialYear;
  final InputDecoration decoration;
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

  @override
  Widget build(BuildContext context) {
    final controller =
        MaskedTextController(text: "$initialMonth/$initialYear", mask: '00/00');

    return Container(
      child: TextFormField(
        validator: validator,
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
        controller: controller,
        decoration: decoration,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
