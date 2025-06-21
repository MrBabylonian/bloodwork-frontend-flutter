import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'navigation/simple_router.dart';
import 'core/providers/patient_provider.dart';
import 'core/providers/analysis_provider.dart';
import 'core/services/service_locator.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ServiceLocator with all dependencies
  await ServiceLocator().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ServiceLocator().authProvider),
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
    return CupertinoApp.router(
      title: 'VetAnalytics',
      debugShowCheckedModeBanner: false,
      routerConfig: SimpleRouter.createRouter(),
    );
  }
}
