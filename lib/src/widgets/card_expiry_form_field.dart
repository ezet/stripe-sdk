import 'package:flutter/material.dart';

import 'masked_text_controller.dart';

class CardExpiryFormField extends StatelessWidget {
  const CardExpiryFormField(
      {Key key,
      this.initialValue,
      @required this.onSaved,
      @required this.validator,
      @required this.onChanged})
      : super(key: key);

  final String initialValue;
  final void Function(int, int) onSaved;
  final void Function(int, int) onChanged;
  final String Function(String) validator;

  @override
  Widget build(BuildContext context) {
    final controller = MaskedTextController(mask: '00/00');
    controller.text = initialValue;
    return Container(
      child: TextFormField(
        validator: validator,
        onChanged: (text) {
          final arr = text.split("/");
          final month = int.tryParse(arr[0]);
          final year = int.tryParse(arr[1]);
          onSaved(month, year);
        },
        onSaved: (text) {
          final arr = text.split("/");
          final month = int.tryParse(arr[0]);
          final year = int.tryParse(arr[1]);
          onSaved(month, year);
        },
        controller: controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Expiry Date',
            hintText: 'MM/YY'),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
