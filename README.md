# Dart Stripe SDK

A native dart package for Stripe. There are various other flutter plugins that wrap existing Stripe libraries,
but this package uses a different approach.
It does not wrap existing Stripe libraries, but instead accesses the Stripe API directly.

## Stripe SCA

This library is currently the only library available for flutter that supports SCA.
It handles SCA by launching the authentication flow in a native browser, and returns the result to the app.

Features:

- Customer session
- PaymentIntent, with SCA
- SetupIntent, with SCA
- Manage customer
- Manage cards
