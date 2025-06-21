import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../components/buttons/index.dart';

/// Simple authentication utilities
class AuthUtils {
  /// Check if user is authenticated, return true if yes, false if no
  static bool isAuthenticated(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated;
  }

  /// Show a simple "please login" screen
  static Widget buildLoginRequiredScreen(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.lock_shield,
                  size: 64,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Text(
                  'Login Richiesto',
                  style: AppTextStyles.title1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'Devi effettuare il login per accedere a questa pagina.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                PrimaryButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Vai al Login'),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                SecondaryButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Torna alla Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to login if not authenticated, otherwise do nothing
  static void requireAuthOrRedirect(BuildContext context) {
    if (!isAuthenticated(context)) {
      context.go('/login');
    }
  }
}
