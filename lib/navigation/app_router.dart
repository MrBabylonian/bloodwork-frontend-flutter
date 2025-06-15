import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../pages/landing_page.dart';
import '../pages/login_page.dart';

/// Application router configuration using go_router
///
/// This handles all navigation within the app and provides
/// URL-based routing for web deployment.
class AppRouter {
  static const String landing = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String upload = '/upload';
  static const String profile = '/profile';
  static const String patientDetails = '/patient';

  /// Creates the router configuration
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: landing,
      routes: [
        // Landing Page (Home)
        GoRoute(
          path: landing,
          name: 'landing',
          builder: (context, state) => const LandingPage(),
        ),

        // Login/Registration Page
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),

        // Dashboard Page (to be implemented)
        GoRoute(
          path: dashboard,
          name: 'dashboard',
          builder:
              (context, state) => const _ComingSoonPage(
                title: 'Dashboard',
                description: 'Patient management dashboard coming soon...',
              ),
        ),

        // Upload Page (to be implemented)
        GoRoute(
          path: upload,
          name: 'upload',
          builder:
              (context, state) => const _ComingSoonPage(
                title: 'Upload',
                description: 'File upload page coming soon...',
              ),
        ),

        // Profile Page (to be implemented)
        GoRoute(
          path: profile,
          name: 'profile',
          builder:
              (context, state) => const _ComingSoonPage(
                title: 'Profile',
                description: 'User profile page coming soon...',
              ),
        ),

        // Patient Details Page (to be implemented)
        GoRoute(
          path: '$patientDetails/:id',
          name: 'patient-details',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? 'unknown';
            return _ComingSoonPage(
              title: 'Patient Details',
              description: 'Patient details for ID: $patientId coming soon...',
            );
          },
        ),
      ],
      errorBuilder: (context, state) => const _NotFoundPage(),
    );
  }
}

/// Temporary page for routes that haven't been implemented yet
class _ComingSoonPage extends StatelessWidget {
  final String title;
  final String description;

  const _ComingSoonPage({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.go('/'),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.gear,
              size: 64,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: CupertinoColors.systemGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 404 Not Found Page
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Page Not Found'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              child: const Text('Go Home'),
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}
