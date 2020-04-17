import 'package:cloud_functions/cloud_functions.dart';
import 'package:get_it/get_it.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'network/network_service.dart';

const _stripePublishableKey = 'pk_test_FlC2pf2JCTgKLcgG0aScSQmp00XqfTJL8s';
const _cloudFunctionsRegion = "europe-west2";
const _returnUrl = "stripesdk://demo.stripesdk.ezet.io";

GetIt locator = GetIt();

void initializeLocator() {
  locator.registerLazySingleton(() => CloudFunctions(region: _cloudFunctionsRegion));
  locator.registerLazySingleton(() => NetworkService(locator.get()));
  Stripe.init(_stripePublishableKey, returnUrlForSca: _returnUrl);
  locator.registerSingleton(CustomerSession((version) => locator.get<NetworkService>().getEphemeralKey(version)));
}
