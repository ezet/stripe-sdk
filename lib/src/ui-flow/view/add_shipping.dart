import 'package:flutter/material.dart';
import 'package:stripe_sdk/src/ui-flow/model/payment_method_models.dart';
import 'payment_methods.dart';

class AttachShippingToPayment extends StatefulWidget {
  ///if this false, shipping details will not be in the ui flow
  final bool attachShipping;

  ///change app bar elevation
  final double appBarElevation;

  ///change app bar background
  final Color appBarBackgroundColor;

  final PaymentMethodModel paymentMethod;
  final CheckoutBuilder checkoutBuilder;

  const AttachShippingToPayment(
    this.paymentMethod, {
    Key key,
    this.attachShipping = false,
    this.appBarElevation,
    this.appBarBackgroundColor,
    @required this.checkoutBuilder,
  })  : assert(paymentMethod != null),
        assert(checkoutBuilder != null),
        super(key: key);

  @override
  _AttachShippingToPaymentState createState() =>
      _AttachShippingToPaymentState();
}

class _AttachShippingToPaymentState extends State<AttachShippingToPayment> {
  final _formKey = GlobalKey<FormState>();
  final _model = AttachShippingToPaymentModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an Address'),
        elevation: widget.appBarElevation,
        backgroundColor: widget.appBarBackgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.checkoutBuilder(
                        context, _model, widget.paymentMethod),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 18),
        child: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            TextFormField(
              initialValue: widget.paymentMethod?.billingDetailModel
                      ?.addressModel?.country ??
                  '',
              keyboardType: TextInputType.name,
              decoration: InputDecoration(labelText: 'Country'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter your country';
                }
                return null;
              },
              onSaved: (value) {
                _model.country = value;
              },
            ),
            TextFormField(
              initialValue:
                  widget.paymentMethod?.billingDetailModel?.name ?? '',
              keyboardType: TextInputType.name,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter your name';
                }
                return null;
              },
              onSaved: (value) {
                _model.name = value;
              },
            ),
            TextFormField(
              initialValue: widget
                      .paymentMethod?.billingDetailModel?.addressModel?.line1 ??
                  '',
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter your address';
                }
                return null;
              },
              onSaved: (value) {
                _model.address = value;
              },
            ),
            TextFormField(
              initialValue: widget
                      .paymentMethod?.billingDetailModel?.addressModel?.line2 ??
                  '',
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(labelText: 'Apt. (optional)'),
              onSaved: (value) {
                _model.apt = value;
              },
            ),
            TextFormField(
              initialValue: widget
                      .paymentMethod?.billingDetailModel?.addressModel?.city ??
                  '',
              keyboardType: TextInputType.name,
              decoration: InputDecoration(labelText: 'City'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter your city';
                }
                return null;
              },
              onSaved: (value) {
                _model.city = value;
              },
            ),
            TextFormField(
              initialValue: widget
                      .paymentMethod?.billingDetailModel?.addressModel?.state ??
                  '',
              keyboardType: TextInputType.name,
              decoration: InputDecoration(labelText: 'State'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter your state';
                }
                return null;
              },
              onSaved: (value) {
                _model.state = value;
              },
            ),
            TextFormField(
              initialValue: widget
                      .paymentMethod?.billingDetailModel?.addressModel?.posta ??
                  '',
              //Some countries outside US sometimes can have none integer zip codes
              keyboardType: TextInputType.text,

              decoration: InputDecoration(labelText: 'ZIP code'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter your zipcode';
                }
                return null;
              },
              onSaved: (value) {
                _model.zipCode = value;
              },
            ),
            TextFormField(
              initialValue:
                  widget.paymentMethod?.billingDetailModel?.phone ?? '',
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone number'),
              validator: (value) {
                var pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                var regExp = RegExp(pattern);
                if (!regExp.hasMatch(value)) {
                  return 'Enter a valid phone';
                }
                return null;
              },
              onSaved: (value) {
                _model.phone = value;
              },
            ),
          ]),
        ),
      ),
    );
  }
}
