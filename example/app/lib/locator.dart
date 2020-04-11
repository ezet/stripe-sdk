import 'package:cloud_functions/cloud_functions.dart';
import 'package:get_it/get_it.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'network/network_service.dart';

GetIt locator = GetIt();

void initializeLocator() {
  locator.registerLazySingleton(() => CloudFunctions(region: "europe-west2"));
  locator.registerLazySingleton(() => NetworkService(locator.get()));
  locator.registerSingleton(Stripe('pk_test_gTROf276lYisD9kQGxPeHOtJ00dT2FrK47'));
  locator.registerSingleton(CustomerSession((version) => locator.get<NetworkService>().getEphemeralKey(version)));
}
