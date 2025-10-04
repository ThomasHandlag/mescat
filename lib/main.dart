import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/themes/app_themes.dart';
import 'core/routes/app_routes.dart';
import 'dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Setup dependency injection
  await setupDependencyInjection();
  
  runApp(const MescatApp());
}

class MescatApp extends StatelessWidget {
  const MescatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mescat',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRoutes.router,
    );
  }
}
