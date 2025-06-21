import 'package:go_router/go_router.dart';

// Import all pages
import '../pages/landing_page.dart';
import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/profile_page.dart';
import '../pages/patient_details_page.dart';
import '../pages/upload_page.dart';

/// Dead simple router - no redirects, no guards, just routing
class SimpleRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        // Landing page
        GoRoute(path: '/', builder: (context, state) => const LandingPage()),

        // Login page
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

        // Dashboard page
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),

        // Profile page
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),

        // Upload page
        GoRoute(
          path: '/upload',
          builder: (context, state) => const UploadPage(),
        ),

        // Upload page with patient ID
        GoRoute(
          path: '/upload/:patientId',
          builder: (context, state) {
            final patientId = state.pathParameters['patientId'] ?? '';
            return UploadPage(patientId: patientId);
          },
        ),

        // Patient details page
        GoRoute(
          path: '/patient/:id',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? '1';
            return PatientDetailsPage(patientId: patientId);
          },
        ),
      ],
    );
  }
}
