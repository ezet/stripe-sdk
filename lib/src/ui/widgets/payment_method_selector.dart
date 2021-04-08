import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../../../stripe_sdk_ui.dart';

typedef OnPaymentMethodSelected = void Function(String?);

class PaymentMethodSelector extends StatefulWidget {
  PaymentMethodSelector(
      {required this.onChanged,
      PaymentMethodStore? paymentMethodStore,
      this.initialPaymentMethodId,
      Key? key,
      this.selectFirstByDefault = true})
      : _paymentMethodStore = paymentMethodStore ?? PaymentMethodStore.instance,
        super(key: key);

  final String? initialPaymentMethodId;
  final OnPaymentMethodSelected onChanged;
  final PaymentMethodStore _paymentMethodStore;
  final bool selectFirstByDefault;

  @override
  _PaymentMethodSelectorState createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  List<PaymentMethod>? paymentMethods;

  PaymentMethod? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    selectedPaymentMethod ??= _getPaymentMethodById(widget.initialPaymentMethodId);
    widget.onChanged(selectedPaymentMethod?.id);
    return Container(
//      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: DropdownButton<String>(
        underline: const SizedBox.shrink(),
        value: selectedPaymentMethod?.id,
        items: paymentMethods
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
            selectedPaymentMethod = _getPaymentMethodById(value);
          });
        },
      ),
    );
  }

  PaymentMethod? _getPaymentMethodById(String? paymentMethodId) {
    if (paymentMethodId != null) {
      return paymentMethods?.singleWhereOrNull((item) => item.id == paymentMethodId);
    } else if (widget.selectFirstByDefault) {
      return paymentMethods != null && paymentMethods!.isNotEmpty ? paymentMethods!.first : null;
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
      paymentMethods = widget._paymentMethodStore.paymentMethods;
    });
  }
}
