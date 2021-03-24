import 'package:cloud_functions/cloud_functions.dart';
import 'package:get_it/get_it.dart';

import 'network/network_service.dart';

const _cloudFunctionsRegion = 'europe-west2';

final locator = GetIt.instance;

void initializeLocator() {
  locator.registerLazySingleton(
      () => FirebaseFunctions.instanceFor(region: _cloudFunctionsRegion));
  locator.registerLazySingleton(() => NetworkService(locator.get()));
}
