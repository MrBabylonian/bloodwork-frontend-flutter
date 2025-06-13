import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'pages/landing_page.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred device orientations (optional)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Run the app with theme provider
  runApp(const VetAnalyticsApp());
}

/// The main application widget for VetAnalytics
class VetAnalyticsApp extends StatelessWidget {
  const VetAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap app with ChangeNotifierProvider for theme management
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      child: Consumer<AppTheme>(
        builder: (context, appTheme, child) {
          return CupertinoApp(
            // App Configuration
            title: 'VetAnalytics',
            debugShowCheckedModeBanner: false,

            // Localization (Italian)
            locale: const Locale('it', 'IT'),

            // Theme Configuration - Using the currentTheme getter
            theme: appTheme.currentTheme,

            // Home Page
            home: const LandingPage(),

            // Route Generation (for future navigation)
            onGenerateRoute: _generateRoute,

            // Initial Route
            initialRoute: '/',
          );
        },
      ),
    );
  }

  /// Route generator for navigation
  /// This will be expanded as we add more pages
  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return CupertinoPageRoute(
          builder: (_) => const LandingPage(),
          settings: settings,
        );

      // Future routes will go here:
      // case '/login':
      //   return CupertinoPageRoute(
      //     builder: (_) => const LoginPage(),
      //     settings: settings,
      //   );
      //
      // case '/dashboard':
      //   return CupertinoPageRoute(
      //     builder: (_) => const DashboardPage(),
      //     settings: settings,
      //   );

      default:
        // Fallback to landing page for unknown routes
        return CupertinoPageRoute(
          builder: (_) => const LandingPage(),
          settings: settings,
        );
    }
  }
}
