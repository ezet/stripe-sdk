import 'package:flutter/material.dart';

import '../../stripe_sdk.dart';
import 'card_number_form_field.dart';

/// Basic form to add or edit a credit card, with complete validation.
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
              initialValue: _validationModel.number ?? widget.card.number,
              onChanged: (number) => _validationModel.number = number,
              validator: (text) =>
                  _validationModel.validateNumber() ? null : "Invalid number",
              onSaved: (text) => widget.card.number = text,
            ),
          ),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(top: 8),
              child: CardExpiryFormField(
                initialMonth: _validationModel.expMonth ?? widget.card.expMonth,
                initialYear: _validationModel.expYear ?? widget.card.expYear,
                onChanged: (int month, int year) {
                  _validationModel.expMonth = month;
                  _validationModel.expYear = year;
                },
                onSaved: (int month, int year) {
                  widget.card.expMonth = month;
                  widget.card.expYear = year;
                },
                validator: (text) =>
                    _validationModel.validateDate() ? null : "Invalid Date",
              )),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            margin: const EdgeInsets.only(top: 8),
            child: CardCvcFormField(
              initialValue: _validationModel.cvc ?? widget.card.cvc,
              onChanged: (text) => _validationModel.cvc = text,
              onSaved: (text) => widget.card.cvc = text,
              validator: (text) =>
                  _validationModel.validateCVC() ? null : "Invalid CVC",
            ),
          ),
        ],
      ),
    );
  }
}
