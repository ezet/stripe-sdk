import 'package:flutter/material.dart';

class CardCvcFormField extends StatelessWidget {
  CardCvcFormField(
      {Key key,
      this.initialValue,
      @required this.onSaved,
      @required this.validator,
      @required this.onChanged})
      : super(key: key);

  final String initialValue;
  final void Function(String) onSaved;
  final void Function(String) onChanged;
  final String Function(String) validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onSaved,
//                  focusNode: cvvFocusNode,
        validator: validator,
        onSaved: onSaved,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'CVV',
          hintText: 'XXXX',
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
