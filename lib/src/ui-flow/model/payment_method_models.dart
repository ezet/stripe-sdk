import 'package:intl/intl.dart';

//Payment Methods List
class PaymentMethodsListModel {
  final List<PaymentMethodModel> data;

  PaymentMethodsListModel({this.data});

  factory PaymentMethodsListModel.fromJsonToList(Map<String, dynamic> json) {
    final list = json['data'] as List;
    final pmm = list.map((p) => PaymentMethodModel.fromJson(p)).toList();
    return PaymentMethodsListModel(data: pmm);
  }
}

//Payment Method
class PaymentMethodModel {
  final String paymentMethodId, customer;
  final int created;
  final BillingDetailModel billingDetailModel;
  final CardModel cardModel;

  PaymentMethodModel({
    this.paymentMethodId,
    this.customer,
    this.created,
    this.billingDetailModel,
    this.cardModel,
  });

  String createdDateFormated(String pattern) {
    final date = DateTime.fromMillisecondsSinceEpoch(created);
    var format = DateFormat(pattern);
    var d = format.format(date);
    return d;
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return PaymentMethodModel(
      paymentMethodId: json['id'],
      customer: json['customer'],
      created: json['created'],
      billingDetailModel: BillingDetailModel.fromJson(json['billing_details']),
      cardModel: CardModel.fromJson(json['card']),
    );
  }

  @override
  String toString() {
    return '{paymentMethodId: $paymentMethodId, customer:$customer, created: $created, formatedCreated: ${createdDateFormated('M/d/y')} billingDetailModel: ${billingDetailModel.toString()}, cardModel:${cardModel.toString()}';
  }
}

//Card
class CardModel {
  final String brand, last4, funding, country;
  final int expYear, expMonth;

  CardModel({
    this.brand,
    this.country,
    this.expYear,
    this.expMonth,
    this.last4,
    this.funding,
  });

  String get capitalizedBrand {
    if (brand == null || brand.isEmpty) {
      return '';
    }
    return brand[0].toUpperCase() + brand.substring(1);
  }

  String get cardImage {
    if (brand == 'cartes_bancaires' || brand.isEmpty || brand == null) {
      return 'unknown.png';
    }
    return brand + '.png';
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return CardModel(
        brand: json['brand'],
        last4: json['last4'],
        funding: json['funding'],
        expMonth: json['exp_month'],
        expYear: json['exp_year'],
        country: json['country']);
  }

  @override
  String toString() {
    return '{brand: $brand, last4: $last4, funding: $funding, expMonth: $expMonth, expYear: $expYear, country: $country}';
  }
}

//Billing Detail

class BillingDetailModel {
  final String name, phone;
  final AddressModel addressModel;

  BillingDetailModel({this.name, this.phone, this.addressModel});

  @override
  String toString() {
    return '{address: ${addressModel.toString()}, name:$name, phone: $phone}';
  }

  factory BillingDetailModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return BillingDetailModel(
      name: json['name'],
      phone: json['phone'],
      addressModel: AddressModel.fromJson(json['address']),
    );
  }
}

//Address
class AddressModel {
  final String city, country, line1, line2, posta, state;

  @override
  String toString() {
    return '{city: $city, country: $country, line1:$line1, line2: $line2, posta: $posta, state: $state}';
  }

  AddressModel(
      {this.city,
      this.country,
      this.line1,
      this.line2,
      this.posta,
      this.state});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return AddressModel(
        city: json['city'],
        country: json['country'],
        line1: json['line1'],
        line2: json['line2'],
        posta: json['postal_code'],
        state: json['state']);
  }
}

//Post Shipping
class AttachShippingToPaymentModel {
  String country, name, address, apt, city, state, phone, zipCode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'phone': phone,
      'address': {
        'city': city,
        'country': country,
        'line1': address,
        'line2': apt,
        'postal_code': zipCode,
        'state': state
      },
    };
  }
}
