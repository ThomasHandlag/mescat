import 'package:get_it/get_it.dart';
import 'core/network/network_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core
  getIt.registerLazySingleton<NetworkService>(() => NetworkService());
  
  // Add other dependencies here as they are implemented
  // Example:
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  // getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase());
}