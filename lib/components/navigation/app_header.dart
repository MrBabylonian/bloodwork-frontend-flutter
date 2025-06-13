import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_gradients.dart';
import '../buttons/ghost_button.dart';

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

  /// Whether to show a back button (automatically determined if null)
  final bool? showBackButton;

  /// Custom back button callback
  final VoidCallback? onBackPressed;

  const AppHeader({
    super.key,
    this.showAuth = true,
    this.onProfileTap,
    this.onLogoutTap,
    this.title,
    this.actions,
    this.backgroundColor,
    this.showBackButton,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final shouldShowBackButton = showBackButton ?? canPop;

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            AppColors.backgroundWhite.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          child: Row(
            children: [
              // Leading section (back button or logo)
              if (shouldShowBackButton)
                _buildBackButton(context)
              else
                _buildLogo(context),

              // Spacer
              const Spacer(),

              // Custom title or default title
              if (title != null)
                title!
              else if (!shouldShowBackButton)
                _buildTitle(context),

              // Spacer
              const Spacer(),

              // Actions section
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GhostButton(
      onPressed: onBackPressed ?? () => Navigator.maybePop(context),
      child: const Icon(CupertinoIcons.chevron_left, size: 20),
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
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'V',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          'VetAnalytics',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'VetAnalytics',
      style: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final defaultActions = <Widget>[];

    if (showAuth) {
      defaultActions.addAll([
        GhostButton(
          onPressed: onProfileTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.person, size: 16),
              const SizedBox(width: AppDimensions.spacingXs),
              Text('Profile', style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        GhostButton(
          onPressed: onLogoutTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.square_arrow_right,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Text(
                'Logout',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
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
