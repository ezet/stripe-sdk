# Stripe SDK Changelog

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
