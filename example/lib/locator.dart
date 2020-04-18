import 'package:cloud_functions/cloud_functions.dart';
import 'package:get_it/get_it.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'network/network_service.dart';


const _cloudFunctionsRegion = "europe-west2";

GetIt locator = GetIt();

void initializeLocator() {
  locator.registerLazySingleton(() => CloudFunctions(region: _cloudFunctionsRegion));
  locator.registerLazySingleton(() => NetworkService(locator.get()));
}
