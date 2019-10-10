import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/widgets/masked_text_controller.dart';

import '../card_utils.dart';

class CardNumberFormField extends StatelessWidget {
  const CardNumberFormField(
      {Key key,
      this.initialText,
      @required this.onSaved,
      @required this.onChanged,
      @required this.validator})
      : super(key: key);

  final void Function(String) onSaved;
  final void Function(String) onChanged;
  final String Function(String) validator;
  final String initialText;

  @override
  Widget build(BuildContext context) {
    final controller = MaskedTextController(mask: '0000 0000 0000 0000');
    controller.text = initialText;
    return Container(
      child: TextFormField(
        controller: controller,
        autovalidate: true,
        onSaved: onSaved,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: getCardTypeIcon(controller.text),
          border: OutlineInputBorder(),
          labelText: 'Card number',
          hintText: 'xxxx xxxx xxxx xxxx',
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
