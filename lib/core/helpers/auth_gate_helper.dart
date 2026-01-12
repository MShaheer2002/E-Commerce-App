import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Helper class to handle authentication gating for restricted actions
class AuthGateHelper {
  /// Check if user is authenticated, show login prompt if not
  /// Returns true if authenticated, false if not
  static bool checkAuthAndPrompt(
    BuildContext context, {
    String? actionMessage,
    VoidCallback? onLoginSuccess,
  }) {
    final auth = context.read<AuthProvider>();

    if (auth.isLoggedIn) {
      return true;
    }

    // Show login prompt
    _showLoginPrompt(
      context,
      actionMessage: actionMessage,
      onLoginSuccess: onLoginSuccess,
    );

    return false;
  }

  /// Show a dialog prompting user to login
  static void _showLoginPrompt(
    BuildContext context, {
    String? actionMessage,
    VoidCallback? onLoginSuccess,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: KprimaryColor, size: 28),
            SizedBox(width: 12),
            Text(
              'Login Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          actionMessage ??
              'You need to be logged in to perform this action.\n\nSign in or create an account to continue.',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: KprimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Navigate to login screen
              context.push('/login').then((_) {
                // Check if user logged in successfully
                final auth = context.read<AuthProvider>();
                if (auth.isLoggedIn && onLoginSuccess != null) {
                  onLoginSuccess();
                }
              });
            },
            child: const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Check if a route requires authentication
  static bool routeRequiresAuth(String route) {
    const authRequiredRoutes = [
      '/checkout-screen',
      '/order-status',
      '/favorite-screen',
      '/profile-setup',
    ];

    return authRequiredRoutes.any((r) => route.startsWith(r));
  }

  /// Routes that are always accessible (even when logged out)
  static bool isPublicRoute(String route) {
    const publicRoutes = [
      '/',
      '/home',
      '/products',
      '/single-product',
      '/category-screen',
      '/product-by-category',
      '/search-screen',
      '/login',
      '/signup',
      '/forgot-password',
      '/webview',
      '/splash',
    ];

    return publicRoutes.any((r) => route.startsWith(r));
  }
}
