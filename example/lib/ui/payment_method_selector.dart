import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk_example/ui/payment_methods_screen.dart';

typedef OnPaymentMethodSelected = void Function(String?);

enum SelectorType { radioButton, dropdownButton }

class PaymentMethodSelector extends StatefulWidget {
  PaymentMethodSelector({
    required this.onChanged,
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

  @override
  _PaymentMethodSelectorState createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  List<PaymentMethod>? _paymentMethods;

  PaymentMethod? _selectedPaymentMethod;
  bool _isLoading = false;

  @override
  void initState() {
    widget._paymentMethodStore.addListener(_updateState);
    _updateState();
    super.initState();
  }

  @override
  void dispose() {
    widget._paymentMethodStore.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {
        _paymentMethods = widget._paymentMethodStore.paymentMethods;
        _isLoading = widget._paymentMethodStore.isLoading;
        if (!_paymentMethods!.contains(_selectedPaymentMethod) || _selectedPaymentMethod == null) {
          if (widget.selectFirstByDefault && _selectedPaymentMethod == null) {
            _selectedPaymentMethod = _paymentMethods?.firstOrNull;
          } else {
            _selectedPaymentMethod = null;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onChanged(_selectedPaymentMethod?.id);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isLoading) _buildSelector() else _buildLoadingIndicator(),
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
                onPressed: () async {
                  final _ = await Navigator.push(
                      context,
                      PaymentMethodsScreen.route(
                          title: 'Payment methods', paymentMethodStore: widget._paymentMethodStore));
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
    return ListView.builder(
      itemCount: _paymentMethods?.length ?? 0,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = _paymentMethods![index];
        return RadioListTile<String?>(
            title: Text(item.brand.toUpperCase()),
            secondary: Text(item.last4),
            subtitle: Text(item.getExpirationAsString()),
            value: item.id,
            groupValue: _selectedPaymentMethod?.id,
            onChanged: (value) => setState(() {
                  _selectedPaymentMethod = _getPaymentMethodById(value);
                  widget.onChanged(_selectedPaymentMethod?.id);
                }));
      },
    );
  }

  Widget _buildDropdownSelector() {
    if (_paymentMethods?.isEmpty == true) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onBackground),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
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
      ),
    );
  }

  PaymentMethod? _getPaymentMethodById(String? paymentMethodId) {
    return _paymentMethods?.singleWhereOrNull((item) => item.id == paymentMethodId);
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator();
  }
}
