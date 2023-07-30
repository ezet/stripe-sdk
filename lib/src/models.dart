class IntentClientSecret {
  final String clientSecret;
  final String? status;

  IntentClientSecret(this.status, this.clientSecret);
}

class PaymentMethod {
  final String id;
  final String last4;
  final String brand;
  final DateTime expirationDate;

  const PaymentMethod(this.id, this.last4, this.brand, this.expirationDate);

  String getExpirationAsString() {
    return '${expirationDate.month}/${expirationDate.year}';
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is PaymentMethod) return id == other.id;
    return false;
  }
}