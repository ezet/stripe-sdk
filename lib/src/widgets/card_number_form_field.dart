import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Form field to edit a credit card number, with validation.
class CardNumberFormField extends StatelessWidget {
  const CardNumberFormField(
      {Key key,
      this.initialValue,
      @required this.onSaved,
      @required this.onChanged,
      @required this.validator,
      this.focusNode,
      this.onFieldSubmitted,
      this.decoration = defaultDecoration,
      this.textStyle = defaultTextStyle,})
      : super(key: key);

  final String initialValue;
  final void Function(String) onSaved;
  final void Function(String) onChanged;
  final String Function(String) validator;
  final FocusNode focusNode;
  final void Function(String) onFieldSubmitted;
  final InputDecoration decoration;
  final TextStyle textStyle;

  static const defaultLabelText = 'Card number';
  static const defaultHintText = 'xxxx xxxx xxxx xxxx';
  static const defaultErrorText = 'Invalid card number';

  static const defaultDecoration = InputDecoration(
    border: OutlineInputBorder(),
    labelText: defaultLabelText,
    hintText: defaultHintText,
  );
  static const defaultTextStyle = TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    var maskFormatter = MaskTextInputFormatter(mask: '#### #### #### ####');
    return Container(
      child: TextFormField(
        initialValue: initialValue,
//        controller: controller,
        inputFormatters: [maskFormatter],
        autovalidate: false,
        onSaved: onSaved,
        validator: validator,
        onChanged: onChanged,
        decoration: decoration,
        style: textStyle,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
