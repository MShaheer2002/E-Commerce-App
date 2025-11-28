import 'dart:developer';

import 'package:e_commerce_app/presentation/models/category_model.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_add_product/admin_add_product_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_analytics/admin_product_analytics_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_banner_management/admin_banner_mangement_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_category_management/admin_category_management_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_dashboard/admin_dashboard.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_edit_product/admin_edit_product_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_global_analytics/admin_global_analytics_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_orders/admin_orders_management_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_orders/admin_single_order_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_products_mangement/admin_products_mangement_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_settings_screen/admin_setting_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_state_sales_tax/admin_state_sales_tax_screen.dart';
import 'package:e_commerce_app/presentation/screens/admin/admin_user_management/admin_user_management_screen.dart';
import 'package:e_commerce_app/presentation/screens/category_screen/category_screen.dart';
import 'package:e_commerce_app/presentation/screens/checkout_screen/checkout_screen.dart';
import 'package:e_commerce_app/presentation/screens/fav_screen/fav_screen.dart';
import 'package:e_commerce_app/presentation/screens/forgot_password/forgot_password.dart';
import 'package:e_commerce_app/presentation/screens/home_screen/home_screen.dart';
import 'package:e_commerce_app/presentation/screens/home_tab/home_tab.dart';
import 'package:e_commerce_app/presentation/screens/login_screen/login_screen.dart';
import 'package:e_commerce_app/presentation/screens/order_status/order_status_screen.dart';
import 'package:e_commerce_app/presentation/screens/product_by_category_screen/product_by_category_screen.dart';
import 'package:e_commerce_app/presentation/screens/products_screen/product_screen.dart';
import 'package:e_commerce_app/presentation/screens/profile_setup/profile_setup.dart';
import 'package:e_commerce_app/presentation/screens/search_screen/search_screen.dart';
import 'package:e_commerce_app/presentation/screens/signup_screen/signup_screen.dart';
import 'package:e_commerce_app/presentation/screens/single_product_screen/single_product_screen.dart';
import 'package:e_commerce_app/presentation/screens/splash_screen/splash_screen.dart';
import 'package:e_commerce_app/presentation/screens/webview/webview_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: authProvider,
    initialLocation: '/splash',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();

      // Wait until Firebase auth is initialized
      if (!auth.isInitialized) return '/splash';

      final isLoggedIn = auth.isLoggedIn;
      final isAdmin = auth.currentRole == "admin";

      final goingToLogin = state.matchedLocation == '/login';
      final goingToSignup = state.matchedLocation == '/signup';
      final goingToSplash = state.matchedLocation == '/splash';
      final goingToForgot = state.matchedLocation == '/forgot-password';
      final goingtoWebview = state.matchedLocation == '/webview';

      // 1️⃣ If user is NOT logged in — only allow splash, login, signup
      if (!isLoggedIn &&
          !(goingToLogin ||
              goingToSignup ||
              goingToSplash ||
              goingToForgot ||
              goingtoWebview)) {
        return '/login';
      }

      // 2️⃣ If user IS logged in — block login/signup/splash
      if (isLoggedIn && (goingToLogin || goingToSignup || goingToSplash)) {
        if (isAdmin) return '/adminDashboard';

        return '/';
      }

      // 3️⃣ Protect adminDashboard — only admins can access it
      if (state.matchedLocation == '/adminDashboard' && !isAdmin) {
        return '/'; // redirect non-admin users to home
      }

      return null; // allow navigation
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
        path: '/order-status',
        builder: (context, state) => const OrderStatusScreen(),
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
        builder: (context, state) {
          final bool isAdmin = state.extra as bool;
          return SearchScreen(
            isAdmin: isAdmin,
          );
        },
      ),
      GoRoute(
        path: '/checkout-screen',
        builder: (context, state) {
          return const CheckoutScreen();
        },
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupView(),
      ),
      GoRoute(
        path: '/adminDashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
          path: '/webview',
          builder: (context, state) {
            final String url = state.extra as String;
            return WebviewScreen(url: url);
          }),

      // ---------------------ADMIN SIDE--------------------------

      GoRoute(
        path: "/admin/customers",
        builder: (context, state) => const AdminUserManagementScreen(),
      ),

      GoRoute(
        path: "/admin/products",
        builder: (context, state) => const AdminProductsMangementScreen(),
      ),
      GoRoute(
        path: "/admin/add-product",
        builder: (context, state) => const AdminAddProductScreen(),
      ),
      GoRoute(
          path: "/admin/edit-product",
          builder: (context, state) {
            final product = state.extra as ProductModel;
            return AdminEditProductScreen(product: product);
          }),

      GoRoute(
        path: "/admin/orders",
        builder: (context, state) => const AdminOrdersManagementScreen(),
      ),

      GoRoute(
          path: "/admin/analytics",
          builder: (context, state) {
            final String productId = state.extra as String;
            return AdminProductAnalyticsScreen(productId: productId);
          }),

      GoRoute(
          path: "/admin/global-analytics",
          builder: (context, state) {
            return const AdminGlobalAnalyticsScreen();
          }),

      GoRoute(
        path: "/admin/settings",
        builder: (context, state) => const AdminSettingScreen(),
      ),

      GoRoute(
        path: "/admin/admin-category",
        builder: (context, state) => const AdminCategoryManagementScreen(),
      ),

      GoRoute(
        path: "/admin/single-order-screen",
        builder: (context, state) {
          final order = state.extra as OrderModel;
          log(" [Single Order Screen] provider ${order}");

          return AdminSingleOrderScreen(order: order);
        },
      ),

      GoRoute(
        path: '/admin/banner-screen',
        builder: (context, state) => const AdminBannerManagementScreen(),
      ),

      GoRoute(
        path: '/admin/states-sales-tax',
        builder: (context, state) => const AdminStateSalesTaxScreen(),
      ),
    ],
  );
}
