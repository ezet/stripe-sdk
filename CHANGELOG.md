# Stripe SDK Changelog

## 2.8.0
* Expose StripeApiException and StripeApiError
* Deprecated Stripe.handlePaymentIntent. Contact me if you used this.
* Deprecated Stripe.handleSetupIntent. Contact me if you used this.
* Deprecated `CustomerSession()` constructor. 3.0 will enforce the singleton pattern.

* Removed experimental parameter `nextAction` from `Stripe.authenticatePayment()`
* Added `Stripe.authenticatePaymentWithNextAction()`

### Experimental: PaymentMethodsScreen
A complete UI screen that lets a user view, delete and add stripe payment methods.

* Slide right to display delete option
* Press `+` to open `AddPaymentMethodScreen`

### Example

* Re-organize example code

## 2.7.0

* Use explicit type for CreateSetupIntent return.
* Added optional [nextAction] parameter to Stripe.authenticatePayment.
* Make [paymentMethodId]  of `Stripe.confirmPayment` optional 

* Fix bug which prevented ephemeral keys from refreshing correctly.

### Example
* Add [Customer Details]
* Add [Payments] with automatic and manual confirmation

## 2.6.0

* Add visual card widget in CardForm

* Fix misc bugs in CardForm

## 2.5.3

* Add focus handling for CardForm.
  * Give card number focus by default.
  * Enable tapping "next/arrow" on keyboard to move to next field.

## 2.5.2
  
* Added a complete demo application, available in /examples/app.
  * Display, add and remove payment methods.
  * Add payment methods with and without Setup Intent.
  * Quickly test pre-made Stripe test cards, with SCA and more.
  
* Made the `StripeApi` instance on `Stripe` objects public. This avoids having to create
a separate StripeApi instance.   

* Fixed bug which prevented ephemeral keys from refreshing correctly.

### Experimental:

* Added "AddPaymentMethod" screen, which handles the complete flow of adding a payment card.
  * This is still WIP and in beta stage, meaning the API might change.

## 2.5.1

Minor breaking change.

* Rename returnUrlForSCA to returnUrlForSca.


## 2.5.0

* Add support for custom return url scheme
* Update documentation

## 2.4.5

* Add links to complete examples of the stripe SDK and supporting backend.

## 2.4.4

* Fix bug which caused initial expiry date not to be set
* Add runnable example in example/app

## 2.4.3

* Add support for custom text style on card form and form fields
* Added examples for card form and form fields

## 2.4.2

* Allow custom form field error text
* Fix bug where card number input field would allow more than 16 digits


## 2.4.1

* Add support for custom input decorators on card form and form fields

## 2.4.0

* Minor breaking change: Split package into two separate sub-libraries:
  * stripe_sdk: API related functionality
  * stripe_sdk_ui: UI widgets and utilities

* Replaced ListView with Column inside the CardForm
* Updated dependencies



## 2.3.0

* Add CardForm widget, which can be used to add or edit credit cards.
  * Complete validation for card number, expiration date and CVC
  * Individual FormField widgets can be used to create a custom form
* Fix bug in Stripe.authenticatePayment

## 2.2.0

* Add support for connected accounts
  * Add optional constructor parameter `stripeAccount` for all APIs

## 2.1.1

* Remove unused stripeAccount property on `StripeApi`

## 2.1.0

* Add Stripe.confirmSetupIntentWithPaymentMethod

## 2.0.0

* Rewrite of internal API
* Fixed several issues and bugs
* Restructured public API with breaking changes
  * Split `Stripe` into `StripeApi` and `Stripe`
  * SCA related features moved to `Stripe`
  * Moved basic Stripe API requests to `StripeApi`

See README and examples for further details details.

## 1.1.1

* Misc minor updates and fixes

## 1.1.0

* Complete support for SetupIntent with SCA
* Fix bug with confirmPayment
* Internal refactoring

## 1.0.1

* Support multiple simultaneous authentication flows
* Improve documentation and examples
* Allow specifying apiVersion for CustomerSession
* Allow multiple instances of Stripe and CustomerSession

## 1.0.0+1

* Improve examples

## 1.0.0

* Improve API for SCA-related features
* Improve examples

## 0.0.2

* Remove typed models
* Add some support for payment intents
* Complete support for payment methods
* Complete support for tokens
* Add examples
* Major cleanup

## 0.0.1+2

* Add analysis_options.yaml
* Fix dartanalyzer issues
* Fix other misc packaging issues

## 0.0.1+1

* Initial release
