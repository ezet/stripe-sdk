# Stripe SDK Changelog

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
