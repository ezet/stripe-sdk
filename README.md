# Flutter Stripe SDK

<https://pub.dev/packages/stripe_sdk>

A native dart package for Stripe. There are various other flutter plugins that wrap existing Stripe libraries,
but this package uses a different approach.
It does not wrap existing Stripe libraries, but instead accesses the Stripe API directly.

See *examples* for additional examples.


## Features

* Supports all types of SCA, including 3DS, 3DS2, BankID and others.
* Handle payments with complete SCA support.
* Add, remove and update payment methods, sources and cards, optionally with SCA.
* Manage customer information.
* Create all types of Stripe tokens.
* Forms, widgets and utilities to use directly, or create your own UI!


### Supported APIs

- PaymentIntent, with SCA
- SetupIntent, with SCA
- PaymentMethod
- Customer
- Cards
- Sources
- Tokens


### Planned features

- Add additional UI widgets
- Support for additional APIs
- Offer complete UI flow for adding payment method
- Offer complete UI flow for checkout


## Overview

- The return type for each function is `Future<Map<String, dynamic>>`, where the value depends on the stripe API version.

The library has three classes to access the Stripe API:

- `Stripe` for generic, non-customer specific APIs, using publishable keys.
- `CustomerSession` for customer-specific APIs, using stripe ephemeral keys.
- `StripeApi` enables raw REST calls against the Stripe API.


### Stripe

- <https://stripe.dev/stripe-android/index.html?com/stripe/android/Stripe.html>

Aims to provide high-level functionality similar to the official mobile Stripe SDKs.

### CustomerSession

_Requires a Stripe ephemeral key._

- <https://stripe.com/docs/mobile/android/customer-information#customer-session-no-ui>
- <https://stripe.com/docs/mobile/android/standard#creating-ephemeral-keys>

Provides functionality similar to CustomerSession in the Stripe Android SDK.

### StripeApi

- <https://stripe.com/docs/api>

Provides basic low-level methods to access the Stripe REST API. 

- Limited to the APIs that can be used with a public key or ephemeral key.
- Library methods map to a Stripe API call with the same name.
- Additional parameters can be provided as an optional argument.


 _`Stripe` and `CustomerSession` use this internally._

## Initialization

All classes offer a singleton instance that can be initated by calling the `init(...)` methods and then accessed through `.instance`.
Regular instances can also be created using the constructor, which allows them to be managed by e.g. dependency injection instead.

### Stripe

```dart
Stripe.init("pk_xxx");
// or, to manage your own instances
final stripe = Stripe("pk_xxx);
```

### CustomerSession

```dart
CustomerSession.init((apiVersion) => server.getEphemeralKeyFromServer(apiVersion));
// or, to manage your own instances
final session = CustomerSession((apiVersion) => server.getEphemeralKeyFromServer(apiVersion))
```

### StripeApi

```dart
StripeApi.init("pk_xxx");
// or, to manage your own instances
final stripeApi = StripeApi("pk_xxx);
```

## UI

Use `CardForm` to add or edit credit card details, or build your own form using the pre-built FormFields.

```dart
final formKey = GlobalKey<FormState>();
final card = StripeCard();

final form = CardForm(card:card, formKey: formKey);
 
onPressed: () async {
                if (formKey.currentState.validate()) {
                  formKey.currentState.save();
                }
}


```

![](docs/cardform.png =250px)         

## SCA/PSD2

The library offers complete support for SCA on iOS and Android.
It handles all types of SCA, including 3DS, 3DS2, BankID and others.
It handles SCA by launching the authentication flow in a web browser, and returns the result to the app.

```dart
Stripe.init("pk_xxx");
final clientSecret = await server.createPaymentIntent(Stripe.getReturnUrl());
final paymentIntent = await Stripe.instance.confirmPayment(clientSecret, "pm_card_visa");
```

### Android

You need to declare this intent filter in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <!-- ... other tags -->
  <application ...>
    <activity ...>
      <!-- ... other tags -->

      <!-- Deep Links -->
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
          android:scheme="stripesdk"
          android:host="3ds.stripesdk.io" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

### IOS

For iOS you need to declare the scheme in
`ios/Runner/Info.plist` (or through Xcode's Target Info editor,
under URL Types):

```xml
<!-- ... other tags -->
<plist>
    <dict>
    <!-- ... other tags -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>3ds.stripesdk.io</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>stripesdk</string>
        </array>
        </dict>
    </array>
    <!-- ... other tags -->
    </dict>
</plist>
```
