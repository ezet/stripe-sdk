import 'models.dart';

typedef CreateSetupIntent = Future<IntentResponse> Function();
typedef CreatePaymentIntent = Future<IntentResponse> Function(int amount);

class StripeUi {
  static late StripeUi _instance;
  final CreateSetupIntent? createSetupIntent;
  final CreatePaymentIntent? createPaymentIntent;

  factory StripeUi() {
    return _instance;
  }

  StripeUi._(this.createSetupIntent, this.createPaymentIntent) {
    _instance = this;
  }

  static void init({CreateSetupIntent? createSetupIntent, CreatePaymentIntent? createPaymentIntent}) {
    StripeUi._(createSetupIntent, createPaymentIntent);
  }
}

void test() {
  // StripeUi().
}
