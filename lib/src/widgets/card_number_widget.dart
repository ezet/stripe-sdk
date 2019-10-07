import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/widgets/masked_text_controller.dart';

import '../card_utils.dart';

class CardNumberWidget extends StatelessWidget {
  const CardNumberWidget({Key key, this.initialText, @required this.onChanged})
      : super(key: key);

  final void Function(String) onChanged;
  final String initialText;

  @override
  Widget build(BuildContext context) {
    final _cardNumberController =
        MaskedTextController(mask: '0000 0000 0000 0000');
    return Container(
      child: TextFormField(
        controller: _cardNumberController,
        autovalidate: true,
        onSaved: (text) => onChanged(text),
        validator: (text) {
          return isValidLuhnNumber(text) ? null : "Invalid number";
        },
        decoration: InputDecoration(
          prefixIcon: getCardTypeIcon(_cardNumberController.text),
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
