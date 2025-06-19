import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'navigation/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/patient_provider.dart';
import 'core/widgets/auth_loading_widget.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (context) => PatientProvider()),
      ],
      child: const VetAnalyticsApp(),
    ),
  );
}

class VetAnalyticsApp extends StatelessWidget {
  const VetAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading widget during initial authentication check
        if (authProvider.status == AuthStatus.initial) {
          return const CupertinoApp(
            home: AuthLoadingWidget(),
            debugShowCheckedModeBanner: false,
          );
        }

        return CupertinoApp.router(
          title: 'VetAnalytics',
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.createRouter(authProvider),
        );
      },
    );
  }
}
