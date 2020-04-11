final _paymentMethods = {
  "data": [
    {
      "id": "pm_1",
      "card": {"brand": "visa", "last4": "1111"}
    },
    {
      "id": "pm_",
      "card": {"brand": "mastercard", "last4": "2222"}
    }
  ]
};

Future<Map> listPaymentMethods() {
  return Future.value(_paymentMethods);
}
