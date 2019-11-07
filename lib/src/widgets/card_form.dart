import 'package:flutter/material.dart';

import '../model/card.dart';
import 'card_cvc_form_field.dart';
import 'card_expiry_form_field.dart';
import 'card_number_form_field.dart';

/// Basic form to add or edit a credit card, with complete validation.
class CardForm extends StatefulWidget {
  CardForm({
    Key key,
    @required this.formKey,
    @required this.card,
    this.cardNumberDecoration,
    this.cardExpiryDecoration,
    this.cardCvcDecoration,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final StripeCard card;
  final InputDecoration cardNumberDecoration;
  final InputDecoration cardExpiryDecoration;
  final InputDecoration cardCvcDecoration;

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
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            margin: const EdgeInsets.only(top: 16),
            child: CardNumberFormField(
              initialValue: _validationModel.number ?? widget.card.number,
              onChanged: (number) => _validationModel.number = number,
              validator: (text) => _validationModel.validateNumber() ? null : "Invalid number",
              onSaved: (text) => widget.card.number = text,
              decoration: widget.cardNumberDecoration ?? CardNumberFormField.defaultDecoration,
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
                validator: (text) => _validationModel.validateDate() ? null : "Invalid Date",
                decoration: widget.cardExpiryDecoration ?? CardExpiryFormField.defaultDecoration,
              )),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            margin: const EdgeInsets.only(top: 8),
            child: CardCvcFormField(
              initialValue: _validationModel.cvc ?? widget.card.cvc,
              onChanged: (text) => _validationModel.cvc = text,
              onSaved: (text) => widget.card.cvc = text,
              validator: (text) => _validationModel.validateCVC() ? null : "Invalid CVC",
              decoration: widget.cardCvcDecoration ?? CardCvcFormField.defaultDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
