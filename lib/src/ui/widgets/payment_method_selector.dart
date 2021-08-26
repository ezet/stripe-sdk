import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../../../stripe_sdk_ui.dart';
import '../stripe_ui.dart';

typedef OnPaymentMethodSelected = void Function(String?);

enum SelectorType { radioButton, dropdownButton }

class PaymentMethodSelector extends StatefulWidget {
  PaymentMethodSelector({
    required this.onChanged,
    this.createSetupIntent,
    PaymentMethodStore? paymentMethodStore,
    this.initialPaymentMethodId,
    this.selectorType = SelectorType.radioButton,
    Key? key,
    this.selectFirstByDefault = false,
  })  : _paymentMethodStore = paymentMethodStore ?? PaymentMethodStore.instance,
        super(key: key);

  final String? initialPaymentMethodId;
  final OnPaymentMethodSelected onChanged;
  final PaymentMethodStore _paymentMethodStore;
  final bool selectFirstByDefault;
  final SelectorType selectorType;
  final CreateSetupIntent? createSetupIntent;

  @override
  _PaymentMethodSelectorState createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  List<PaymentMethod>? _paymentMethods;

  PaymentMethod? _selectedPaymentMethod;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _selectedPaymentMethod ??= _getPaymentMethodById(widget.initialPaymentMethodId);
    return Column(
      children: [
        if (!_isLoading)
          _buildSelector()
        else
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildLoadingIndicator(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
                onPressed: () async {
                  final id = await Navigator.push(
                      context,
                      AddPaymentMethodScreen.routeWithSetupIntent(widget.createSetupIntent!,
                          paymentMethodStore: widget._paymentMethodStore));
                  if (id != null) {
                    await widget._paymentMethodStore.refresh();
                    setState(() {
                      _selectedPaymentMethod = _getPaymentMethodById(id);
                    });
                  }
                },
                child: const Text('+ Add card')),
            OutlinedButton(
                onPressed: () async {
                  final _ = await Navigator.push(
                      context,
                      PaymentMethodsScreen.route(
                          createSetupIntent: widget.createSetupIntent!,
                          title: '',
                          paymentMethodStore: widget._paymentMethodStore));
                },
                child: const Text('Manage cards')),
          ],
        )
      ],
    );
  }

  Widget _buildSelector() {
    switch (widget.selectorType) {
      case SelectorType.radioButton:
        return _buildRadioListSelector();
      case SelectorType.dropdownButton:
        return _buildDropdownSelector();
    }
  }

  Widget _buildRadioListSelector() {
    if (_paymentMethods?.isEmpty == true) return const SizedBox.shrink();
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: _paymentMethods!
          .map((item) => RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: Text(item.brand.toUpperCase()),
              secondary: Text('**** **** **** ${item.last4}'),
              subtitle: Text(item.getExpirationAsString()),
              value: item.id,
              groupValue: _selectedPaymentMethod?.id,
              onChanged: (value) => setState(() {
                    _selectedPaymentMethod = _getPaymentMethodById(value);
                    widget.onChanged(_selectedPaymentMethod?.id);
              })))
          .toList(),
    );
  }

  Widget _buildDropdownSelector() {
    if (_paymentMethods?.isEmpty == true) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: DropdownButton<String>(
        underline: const SizedBox.shrink(),
        value: _selectedPaymentMethod?.id,
        items: _paymentMethods
            ?.map((item) => DropdownMenuItem(
                  value: item.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text('${item.brand.toUpperCase()} **** **** **** ${item.last4}'),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = _getPaymentMethodById(value);
          });
        },
      ),
    );
  }

  PaymentMethod? _getPaymentMethodById(String? paymentMethodId) {
    if (paymentMethodId != null) {
      return _paymentMethods?.singleWhereOrNull((item) => item.id == paymentMethodId);
    } else if (widget.selectFirstByDefault) {
      return _paymentMethods != null && _paymentMethods!.isNotEmpty ? _paymentMethods!.first : null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    widget._paymentMethodStore.addListener(listener);
  }

  @override
  void dispose() {
    widget._paymentMethodStore.removeListener(listener);
    super.dispose();
  }

  void listener() {
    setState(() {
      _paymentMethods = widget._paymentMethodStore.paymentMethods;
      _isLoading = widget._paymentMethodStore.isLoading;
    });
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator();
  }
}
