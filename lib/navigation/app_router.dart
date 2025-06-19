import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../pages/landing_page.dart';
import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/profile_page.dart';
import '../pages/patient_details_page.dart';
import '../pages/upload_page.dart';
import '../core/providers/auth_provider.dart';

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

  /// Creates the router configuration with authentication support
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: landing,
      refreshListenable: authProvider, // Listen to auth state changes
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;
        final currentLocation = state.matchedLocation;

        // Debug logging to track routing behavior
        print('🔄 ROUTER REDIRECT:');
        print('   Current Location: $currentLocation');
        print('   Is Authenticated: $isAuthenticated');
        print('   Is Loading: $isLoading');
        print('   Auth Status: ${authProvider.status}');

        // CRITICAL: Don't redirect while authentication is in progress
        if (isLoading) {
          print('   ➡️ Loading - no redirect');
          return null;
        }

        // If authenticated user is on login page, redirect to dashboard
        if (isAuthenticated && currentLocation == login) {
          print(
            '   ➡️ Authenticated user on login page → redirecting to dashboard',
          );
          return dashboard;
        }

        // If authenticated user is on landing page, redirect to dashboard
        if (isAuthenticated && currentLocation == landing) {
          print(
            '   ➡️ Authenticated user on landing page → redirecting to dashboard',
          );
          return dashboard;
        }

        // Protected routes - redirect unauthenticated users to login
        final protectedRoutes = [dashboard, upload, profile];
        final isProtectedRoute = protectedRoutes.any(
          (route) =>
              currentLocation.startsWith(route) ||
              currentLocation == patientDetails,
        );

        if (!isAuthenticated && isProtectedRoute) {
          print(
            '   ➡️ Unauthenticated user accessing protected route → redirecting to login',
          );
          return login;
        }

        print('   ➡️ No redirect needed');
        return null;
      },
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

        // Dashboard Page
        GoRoute(
          path: dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardPage(),
        ),

        // Upload Page
        GoRoute(
          path: upload,
          name: 'upload',
          builder: (context, state) => const UploadPage(),
        ),

        // Profile Page
        GoRoute(
          path: profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),

        // Patient Details Page
        GoRoute(
          path: '$patientDetails/:id',
          name: 'patient-details',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? '1';
            return PatientDetailsPage(patientId: patientId);
          },
        ),
      ],
      errorBuilder: (context, state) => const _NotFoundPage(),
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
