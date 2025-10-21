import 'package:e_commerce_app/presentation/models/cart_model.dart';
import 'package:e_commerce_app/presentation/models/category_model.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/screens/category_screen/category_screen.dart';
import 'package:e_commerce_app/presentation/screens/checkout_screen/checkout_screen.dart';
import 'package:e_commerce_app/presentation/screens/fav_screen/fav_screen.dart';
import 'package:e_commerce_app/presentation/screens/home_screen/home_screen.dart';
import 'package:e_commerce_app/presentation/screens/home_tab/home_tab.dart';
import 'package:e_commerce_app/presentation/screens/login_screen/login_screen.dart';
import 'package:e_commerce_app/presentation/screens/product_by_category_screen/product_by_category_screen.dart';
import 'package:e_commerce_app/presentation/screens/products_screen/product_screen.dart';
import 'package:e_commerce_app/presentation/screens/search_screen/search_screen.dart';
import 'package:e_commerce_app/presentation/screens/signup_screen/signup_screen.dart';
import 'package:e_commerce_app/presentation/screens/single_product_screen/single_product_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce_app/presentation/screens/splash_screen/splash_screen.dart';

// Inside createRouter()
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: authProvider,
    initialLocation: '/splash',
    redirect: (context, state) {
      // final auth = context.read<AuthProvider>();
      // final isLoggedIn = auth.isLoggedIn;

      // // Skip redirect during splash
      // if (state.matchedLocation == '/splash') return null;

      // final goingToLogin = state.matchedLocation == '/login';
      // final goingToSignup = state.matchedLocation == '/signup';

      // if (!isLoggedIn && !(goingToLogin || goingToSignup)) return '/login';
      // if (isLoggedIn && (goingToLogin || goingToSignup)) return '/';
      // return null;

      final auth = context.read<AuthProvider>();

      // Wait until provider has seen the first authStateChanges event
      if (!auth.isInitialized) return '/splash';

      final isLoggedIn = auth.isLoggedIn;
      final goingToLogin = state.matchedLocation == '/login';
      final goingToSignup = state.matchedLocation == '/signup';
      final goingToSplash = state.matchedLocation == '/splash';

      if (!isLoggedIn && !(goingToLogin || goingToSignup || goingToSplash)) {
        return '/login';
      }
      if (isLoggedIn && (goingToLogin || goingToSignup || goingToSplash)) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeTab(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductScreen(),
      ),
      GoRoute(
        path: '/single-product',
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return SingleProductScreen(productModel: product);
        },
      ),
      GoRoute(
        path: '/category-screen',
        builder: (context, state) => const CategoryScreen(),
      ),
      GoRoute(
        path: '/product-by-category',
        builder: (context, state) {
          final category = state.extra as CategoryModel;
          return ProductByCategoryScreen(categoryModel: category);
        },
      ),
      GoRoute(
        path: '/favorite-screen',
        builder: (context, state) => const FavScreen(),
      ),
      GoRoute(
        path: '/search-screen',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/checkout-screen',
        builder: (context, state) {
          final items = state.extra as List<CartModel>;
          return CheckoutScreen(
            selectedItems: items,
          );
        },
      ),
    ],
  );
}
