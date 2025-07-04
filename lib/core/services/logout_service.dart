import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../components/dialogs/app_custom_dialog.dart';

/// Service to handle logout functionality consistently across the app
class LogoutService {
  /// Shows logout confirmation dialog and handles logout if confirmed
  static Future<void> showLogoutDialog(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Conferma Logout',
      message: 'Sei sicuro di voler uscire dal tuo account?',
      confirmText: 'Esci',
      cancelText: 'Annulla',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await _performLogout(context);
    }
  }

  /// Performs the actual logout process
  static Future<void> _performLogout(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      // Navigate to login page after successful logout
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      // Even if logout fails, try to navigate to login
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}
