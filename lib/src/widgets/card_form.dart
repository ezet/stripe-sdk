import 'package:flutter/material.dart';

import '../../stripe_sdk.dart';
import 'card_number_form_field.dart';

class CardForm extends StatefulWidget {
  CardForm({Key key, @required this.formKey, @required this.card})
      : super(key: key);

  final GlobalKey<FormState> formKey;
  final StripeCard card;

  @override
  _CardFormState createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final StripeCard _validationModel = StripeCard();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            margin: const EdgeInsets.only(top: 16),
            child: CardNumberFormField(
              initialText: widget.card.number,
              onChanged: (number) => _validationModel.number = number,
              validator: (text) =>
                  _validationModel.validateNumber() ? null : "Invalid number",
              onSaved: (text) => widget.card.number = _validationModel.number,
            ),
          ),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(top: 8),
              child: CardExpiryFormField(
                onSaved: (int month, int year) {
                  _validationModel.expMonth = month;
                  _validationModel.expYear = year;
                },
                onChanged: (int month, int year) {
                  widget.card.expMonth = _validationModel.expMonth;
                  widget.card.expYear = _validationModel.expYear;
                },
                validator: (text) =>
                    _validationModel.validateDate() ? null : "Invalid Date",
              )),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            margin: const EdgeInsets.only(top: 8),
            child: CardCvcFormField(
              onSaved: (text) => _validationModel.cvc = text,
              onChanged: (text) => widget.card.cvc = _validationModel.cvc,
              validator: (text) =>
                  _validationModel.validateCVC() ? null : "Invalid CVC",
            ),
          ),
        ],
      ),
    );
  }
}
