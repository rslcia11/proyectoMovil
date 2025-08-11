import 'package:get_it/get_it.dart';
import '../services/field_service.dart';
import '../services/auth_service.dart'; // Import AuthService

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register services
  locator.registerLazySingleton<FieldService>(() => FieldService());
  locator.registerLazySingleton<AuthService>(() => AuthService()); // Register AuthService
  // Add other services here
}
