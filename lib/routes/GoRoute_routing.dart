import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/screens/cart_screen/cart_screen.dart';
import 'package:e_commerce_app/presentation/screens/home_screen/home_screen.dart';
import 'package:e_commerce_app/presentation/screens/login_screen/login_screen.dart';
import 'package:e_commerce_app/presentation/screens/notification_screen/notification_screen.dart';
import 'package:e_commerce_app/presentation/screens/profile_screen/profile_screen.dart';
import 'package:e_commerce_app/presentation/screens/settings_screen/setting_screen.dart';
import 'package:e_commerce_app/presentation/screens/signup_screen/signup_screen.dart';
import 'package:e_commerce_app/routes/profile_route.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: authProvider, // ✅ works now!
    initialLocation: '/',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggedIn = auth.isLoggedIn;
      final goingToLogin = state.matchedLocation == '/login';
      final goingToSignup = state.matchedLocation == '/signup';

      if (!isLoggedIn && !(goingToLogin || goingToSignup)) return '/login';
      if (isLoggedIn && (goingToLogin || goingToSignup)) return '/';
      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // GoRoute(
      //   path: '/',
      //   builder: (context, state) => const HomeScreen(),
      // ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ProfileRoute(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
          GoRoute(
              path: '/notification',
              builder: (_, __) => const NotificationScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingScreen()),
        ],
      ),
    ],
  );
}
