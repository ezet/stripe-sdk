import 'stripe_json_model.dart';

class SourceReceiver extends StripeJsonModel {
  static const String FIELD_ADDRESS = "address";
  static const String FIELD_AMOUNT_CHARGED = "amount_charged";
  static const String FIELD_AMOUNT_RECEIVED = "amount_received";
  static const String FIELD_AMOUNT_RETURNED = "amount_returned";

  // This is not to be confused with the Address object
  String address;
  int amountCharged;
  int amountReceived;
  int amountReturned;

  //
  SourceReceiver({
    this.address,
    this.amountCharged,
    this.amountReceived,
    this.amountReturned,
  });

  SourceReceiver.fromJson(Map<String, dynamic> json) {
    address = json[FIELD_ADDRESS];
    amountCharged = json[FIELD_AMOUNT_CHARGED];
    amountReceived = json[FIELD_AMOUNT_RECEIVED];
    amountReturned = json[FIELD_AMOUNT_RETURNED];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> hashMap = new Map();

    hashMap[FIELD_ADDRESS] = address;
    hashMap[FIELD_AMOUNT_CHARGED] = amountCharged;
    hashMap[FIELD_AMOUNT_RECEIVED] = amountReceived;
    hashMap[FIELD_AMOUNT_RETURNED] = amountReturned;
    return hashMap;
  }
}
