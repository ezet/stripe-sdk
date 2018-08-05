# Flutter Stripe API
A flutter plugin to integrate stripe into flutter app. There are other pluging available but I tried a different approach. (This plugin not dependent on any other native stripe library)
I start to follow the official Android stripe SDK and replicate it's code into Dart. So far I completed the basic functions which includes:
- Start Customer Session
- End Customer Session
- Get Customer
- Create Card Token
- Add Customer Source
- Remove Customer Source
- Update Default Source
- Update Customer Shipping Information (not tested)

This plugin is in very initial stage, I am using it in my personal app. Future plan is to complete all the remaining API. And completing the Example Project with proper UI. And also having a TextInputFormatter for card auto complete and validation.
