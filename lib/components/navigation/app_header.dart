import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../buttons/index.dart';

/// A header component for the application
///
/// Provides a fixed app bar with branding, navigation, and auth controls.
/// Supports both authenticated and unauthenticated states.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Whether to show authentication controls
  final bool showAuth;

  /// Callback when profile button is tapped
  final VoidCallback? onProfileTap;

  /// Callback when logout button is tapped
  final VoidCallback? onLogoutTap;

  /// Custom title widget (overrides default branding)
  final Widget? title;

  /// Custom actions to show on the right side
  final List<Widget>? actions;

  /// Background color override
  final Color? backgroundColor;

  const AppHeader({
    super.key,
    this.showAuth = true,
    this.onProfileTap,
    this.onLogoutTap,
    this.title,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingL,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            AppColors.backgroundWhite.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: AppColors.borderGray, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Always show logo (branding)
            _buildLogo(context),

            // Custom title (show if provided)
            if (title != null) Expanded(child: Center(child: title!)),

            // Actions section
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, Color(0xFF4A90E2)],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: const Center(
            child: Text(
              'V',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          'VetAnalytics',
          style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.warningOrange,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: const Text(
            'BETA',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final defaultActions = <Widget>[];

    if (showAuth) {
      defaultActions.addAll([
        GhostButton(
          size: ButtonSize.small,
          onPressed: onProfileTap,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.person, size: 16),
              SizedBox(width: AppDimensions.spacingXs),
              Text('Profilo'),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        GhostButton(
          size: ButtonSize.small,
          onPressed: onLogoutTap,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.arrow_right_square, size: 16),
              SizedBox(width: AppDimensions.spacingXs),
              Text('Esci'),
            ],
          ),
        ),
      ]);
    }

    if (actions != null) {
      defaultActions.addAll(actions!);
    }

    return Row(mainAxisSize: MainAxisSize.min, children: defaultActions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(72); // 56 + 16 (standard toolbar height + padding)
}

/// A specialized app header for authenticated screens
class AuthenticatedAppHeader extends StatelessWidget
    implements PreferredSizeWidget {
  /// Callback when profile button is tapped
  final VoidCallback? onProfileTap;

  /// Callback when logout button is tapped
  final VoidCallback? onLogoutTap;

  /// Custom actions to show on the right side
  final List<Widget>? actions;

  const AuthenticatedAppHeader({
    super.key,
    this.onProfileTap,
    this.onLogoutTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      showAuth: true,
      onProfileTap: onProfileTap,
      onLogoutTap: onLogoutTap,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72); // 56 + 16 (standard toolbar height + padding)
}

/// A specialized app header for unauthenticated screens
class UnauthenticatedAppHeader extends StatelessWidget
    implements PreferredSizeWidget {
  /// Custom actions to show on the right side
  final List<Widget>? actions;

  const UnauthenticatedAppHeader({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppHeader(showAuth: false, actions: actions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(72); // 56 + 16 (standard toolbar height + padding)
}

/// A specialized header for the landing page with login/signup buttons
class LandingHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Callback when login button is tapped
  final VoidCallback? onLoginTap;

  /// Callback when signup/start button is tapped
  final VoidCallback? onStartTap;

  /// Background color override
  final Color? backgroundColor;

  const LandingHeader({
    super.key,
    this.onLoginTap,
    this.onStartTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      showAuth: false,
      backgroundColor: backgroundColor,
      actions: [
        GhostButton(
          size: ButtonSize.small,
          onPressed: onLoginTap ?? () => context.go('/login'),
          child: const Text('Accedi'),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        PrimaryButton(
          size: ButtonSize.small,
          onPressed: onStartTap ?? () => context.go('/login'),
          child: const Text('Inizia'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72); // 56 + 16 (standard toolbar height + padding)
}

/// A specialized header for the login/registration page with just a back button
class LoginHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Callback when back button is tapped
  final VoidCallback? onBackTap;

  /// Background color override
  final Color? backgroundColor;

  const LoginHeader({super.key, this.onBackTap, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingL,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            AppColors.backgroundWhite.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: AppColors.borderGray, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            GhostButton(
              size: ButtonSize.small,
              onPressed: onBackTap ?? () => context.go('/'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.chevron_left, size: 16),
                  SizedBox(width: AppDimensions.spacingXs),
                  Text('Torna alla Home'),
                ],
              ),
            ),

            // Empty space to push the back button to the left
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72); // 56 + 16 (standard toolbar height + padding)
}
