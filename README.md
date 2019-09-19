# Flutter Stripe SDK

A native dart package for Stripe. There are various other flutter plugins that wrap existing Stripe libraries,
but this package uses a different approach.
It does not wrap existing Stripe libraries, but instead accesses the Stripe API directly.

See *examples* for additional examples.

## Features

- Customer session
- PaymentIntent, with SCA
- SetupIntent, with SCA
- Manage customer
- Manage cards and sources

## Basic use

The library offers two main API surfaces:

- `Stripe` for generic, non-customer specific APIs.
- `CustomerSession` for customer-specific APIs.

## Initialization

Both classes offer a singleton instance that can be initated by calling the `init(...)` methods and then accessed through `.instance`.

Regular instances can also be created using the constructor, which allows them to be managed by e.g. dependency injection instead.

## SCA/PSD2

The library offers complete support for SCA.
It handles SCA by launching the authentication flow in a native browser, and returns the result to the app.

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
