 import 'package:flutter_test/flutter_test.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

 void main() {
   setUpAll(() {
     Stripe.init('pk_test_gTROf276lYisD9kQGxPeHOtJ00dT2FrK47');
   });

   test('Get payment intent', () {
//     Stripe.instance.retrievePaymentIntent(clientSecret)
     //final calculator = new Calculator();
     //expect(calculator.addOne(2), 3);
     //expect(calculator.addOne(-7), -6);
     //expect(calculator.addOne(0), 1);
     //expect(() => calculator.addOne(null), throwsNoSuchMethodError);
   });
 }
