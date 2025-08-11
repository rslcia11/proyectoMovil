import 'package:get_it/get_it.dart';
import '../services/field_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register services
  locator.registerLazySingleton<FieldService>(() => FieldService());
  // Add other services here
}
