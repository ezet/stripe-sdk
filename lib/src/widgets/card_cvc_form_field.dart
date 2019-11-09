import 'package:flutter/material.dart';

import 'masked_text_controller.dart';

/// Form field to edit a credit card CVC code, with validation
class CardCvcFormField extends StatelessWidget {
  CardCvcFormField(
      {Key key,
      this.initialValue,
      @required this.onSaved,
      @required this.validator,
      @required this.onChanged,
      this.decoration = defaultDecoration})
      : super(key: key);

  final String initialValue;
  final InputDecoration decoration;
  final void Function(String) onSaved;
  final void Function(String) onChanged;
  final String Function(String) validator;

  static const defaultDecoration = InputDecoration(
      border: OutlineInputBorder(), labelText: "CVV", hintText: "XXX");

  @override
  Widget build(BuildContext context) {
    final controller = MaskedTextController(text: initialValue, mask: '0000');
    ;
    return Container(
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        onSaved: onSaved,
        decoration: decoration,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
