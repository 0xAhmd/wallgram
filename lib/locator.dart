import 'package:get_it/get_it.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/user_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Register AuthService as a singleton (one instance for app lifecycle)
  locator.registerLazySingleton<AuthService>(() => AuthService());

  // Register UserService as a singleton
  // UserService depends on AuthService internally via locator, so no parameters here
  locator.registerLazySingleton<UserService>(() => UserService());
}
