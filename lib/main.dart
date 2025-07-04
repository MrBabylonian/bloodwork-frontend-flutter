import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/simple_router.dart';
import 'core/providers/patient_provider.dart';
import 'core/providers/analysis_provider.dart';
import 'core/services/service_locator.dart';
import 'theme/app_theme.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ServiceLocator with all dependencies
  await ServiceLocator().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ServiceLocator().authProvider),
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (context) => PatientProvider()),
        ChangeNotifierProvider(create: (context) => AnalysisProvider()),
      ],
      child: const VetAnalyticsApp(),
    ),
  );
}

class VetAnalyticsApp extends StatelessWidget {
  const VetAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(
      builder:
          (context, appTheme, _) => MaterialApp.router(
            title: 'VetAnalytics',
            debugShowCheckedModeBanner: false,
            theme: appTheme.lightTheme,
            darkTheme: appTheme.darkTheme,
            themeMode: appTheme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: SimpleRouter.createRouter(),
            // Enable Material 3 globally
            // Note: individual widgets already opt-in via ThemeData.useMaterial3
          ),
    );
  }
}
