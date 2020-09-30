# Example UI Flow

This is a sample example of using this sdk for a UI Flow payment. The design simply tries to achieve a similar look as Stripe's Android Pre-Built UI Flow. 
The UI Flow has a built in handling of errors, exceptions, and also provides a sample example showing how to handle errors from the server side. It is a simpler way that tries to give a quick start to plug into your app and start processing payments. The steps required to make this work is noted in the `example_uiflow` flutter app project containing 2 files: The main.dart and api_service.dart showing how it works with simple server.

1. Simply initialize the Stripe and CustomerSession objects
2. Send your customer to the `PaymentMethods()` Widget when your customer is ready to make a purchase. This will take your customer on a payment flow from adding a payment or selecting a payment to adding shipping address, and finally displaying a final message of checkout message. 
3. Note `PaymentMethods()` class has a boolean `withShippingPage` property that gives you the option of making your customer to include shipping address, a `Future<SetupIntentModel> Function()` property that comes from your server that allows the customer to set-up payment by adding payment(Look at this simple [node server code](https://github.com/eyoeldefare/simp_server) needed to run this whole operation to get an idea), `CardForm() cardForm` property giving you the option to customize the design of adding payment page, and finally, `Widget Function(BuildContext, AttachShippingToPaymentModel, PaymentMethodModel) checkoutBuilder` which brings your the customer's shipping details and payment method information altogether so you can make payment intent with them and also display a checkout message in the end. 
4. Again, checkout the `ApiService` class that interacts with this [simple node server](https://github.com/eyoeldefare/simp_server) to see how it all works.

## Sample UI Flow Snapshots

Here, you will be able to see the UI flow in order from start to end.

<img src="https://raw.githubusercontent.com/eyoeldefare/textfield_tags/master/images/0_pay.png" width="350">

<img src="https://raw.githubusercontent.com/eyoeldefare/textfield_tags/master/images/1_payment_methods.png" width="350">

<img src="https://raw.githubusercontent.com/eyoeldefare/textfield_tags/master/images/2_add_card.png" width="350">

<img src="https://raw.githubusercontent.com/eyoeldefare/textfield_tags/master/images/3_error_handle.png" width="350">

<img src="https://raw.githubusercontent.com/eyoeldefare/textfield_tags/master/images/4_add_address.png" width="350">

<img src="https://raw.githubusercontent.com/eyoeldefare/textfield_tags/master/images/5_final_checkout_display.png" width="350">