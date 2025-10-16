import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/screens/home_screen/home_screen.dart';
import 'package:e_commerce_app/presentation/screens/home_tab/home_tab.dart';
import 'package:e_commerce_app/presentation/screens/login_screen/login_screen.dart';
import 'package:e_commerce_app/presentation/screens/products_screen/product_screen.dart';
import 'package:e_commerce_app/presentation/screens/signup_screen/signup_screen.dart';
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
        path: '/',
        builder: (context, state) => const HomeTab(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductScreen(),
      ),
    ],
  );
}
