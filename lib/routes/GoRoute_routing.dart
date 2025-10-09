import 'package:e_commerce_app/core/providers/auth_notifier.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/screens/home_screen/home_screen.dart';
import 'package:e_commerce_app/presentation/screens/login_screen/login_screen.dart';
import 'package:e_commerce_app/presentation/screens/signup_screen/signup_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter createRouter(AuthNotifier authNotifier) {
  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: authNotifier, // ✅ works now!
    initialLocation: '/',

    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggedIn = auth.isLoggedIn;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';

      // If user is not logged in, only allow /login or /signup
      if (!isLoggedIn && !isGoingToLogin && !isGoingToSignup) {
        return '/login';
      }

      // If logged in and tries to go to login or signup, send them home
      if (isLoggedIn && (isGoingToLogin || isGoingToSignup)) {
        return '/';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
    ],
  );
}
