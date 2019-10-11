import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/widgets/masked_text_controller.dart';

/// Form field to edit a credit card number, with validation.
class CardNumberFormField extends StatelessWidget {
  const CardNumberFormField(
      {Key key,
      this.initialValue,
      @required this.onSaved,
      @required this.onChanged,
      @required this.validator})
      : super(key: key);

  final void Function(String) onSaved;
  final void Function(String) onChanged;
  final String Function(String) validator;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    final controller = MaskedTextController(text: initialValue, mask: '0000 0000 0000 0000');
    return Container(
      child: TextFormField(
        controller: controller,
        autovalidate: false,
        onSaved: onSaved,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          // prefixIcon: getCardTypeIcon(controller.text),
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
