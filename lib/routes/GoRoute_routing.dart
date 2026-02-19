import 'dart:developer';

import 'package:ProductPlug/presentation/models/category_model.dart';
import 'package:ProductPlug/presentation/models/order_model.dart';
import 'package:ProductPlug/presentation/models/product_model.dart';
import 'package:ProductPlug/presentation/providers/auth_provider.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_add_product/admin_add_product_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_analytics/admin_product_analytics_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_banner_management/admin_banner_mangement_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_category_management/admin_category_management_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_dashboard/admin_dashboard.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_edit_product/admin_edit_product_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_global_analytics/admin_global_analytics_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_orders/admin_orders_management_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_orders/admin_single_order_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_products_mangement/admin_products_mangement_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_settings_screen/admin_setting_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_state_sales_tax/admin_state_sales_tax_screen.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_user_management/admin_user_management_screen.dart';
import 'package:ProductPlug/presentation/screens/category_screen/category_screen.dart';
import 'package:ProductPlug/presentation/screens/checkout_screen/checkout_screen.dart';
import 'package:ProductPlug/presentation/screens/fav_screen/fav_screen.dart';
import 'package:ProductPlug/presentation/screens/forgot_password/forgot_password.dart';
import 'package:ProductPlug/presentation/screens/home_screen/home_screen.dart';
import 'package:ProductPlug/presentation/screens/home_tab/home_tab.dart';
import 'package:ProductPlug/presentation/screens/login_screen/login_screen.dart';
import 'package:ProductPlug/presentation/screens/order_status/order_status_screen.dart';
import 'package:ProductPlug/presentation/screens/product_by_category_screen/product_by_category_screen.dart';
import 'package:ProductPlug/presentation/screens/products_screen/product_screen.dart';
import 'package:ProductPlug/presentation/screens/profile_setup/profile_setup.dart';
import 'package:ProductPlug/presentation/screens/search_screen/search_screen.dart';
import 'package:ProductPlug/presentation/screens/signup_screen/signup_screen.dart';
import 'package:ProductPlug/presentation/screens/single_product_screen/single_product_screen.dart';
import 'package:ProductPlug/presentation/screens/splash_screen/splash_screen.dart';
import 'package:ProductPlug/presentation/screens/webview/webview_screen.dart';
import 'package:flutter/material.dart';
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

      // 0️⃣ Force navigation if requested (e.g. after account delete)
      if (auth.shouldNavigateToHome) return '/';

      final isLoggedIn = auth.isLoggedIn;
      final isAdmin = auth.currentRole == "admin";
      final currentLocation = state.matchedLocation;

      // Public routes accessible without login
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

      // Routes that require authentication
      const authRequiredRoutes = [
        '/checkout-screen',
        '/order-status',
        '/favorite-screen',
        '/profile-setup',
      ];

      final isPublicRoute =
          publicRoutes.any((r) => currentLocation.startsWith(r));
      final requiresAuth =
          authRequiredRoutes.any((r) => currentLocation.startsWith(r));

      // 1️⃣ Allow splash screen always
      if (currentLocation == '/splash') return null;

      // 2️⃣ If user IS logged in — block login/signup/splash
      if (isLoggedIn &&
          (currentLocation == '/login' ||
              currentLocation == '/signup' ||
              currentLocation == '/splash')) {
        if (isAdmin) return '/adminDashboard';
        return '/';
      }

      // 3️⃣ Protect routes that require authentication
      if (!isLoggedIn && requiresAuth) {
        return '/login';
      }

      // 4️⃣ Protect adminDashboard — only admins can access it
      if (currentLocation.startsWith('/admin') && !isAdmin) {
        return '/'; // redirect non-admin users to home
      }

      // Force Admin to Dashboard if at root
      if (isAdmin && currentLocation == '/') {
        return '/adminDashboard';
      }

      // 5️⃣ Allow public routes for everyone (guest browsing)
      if (isPublicRoute) return null;

      return null; // allow navigation
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const HomeTab(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/products',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const ProductScreen(),
        ),
      ),
      GoRoute(
        path: '/single-product',
        pageBuilder: (context, state) {
          if (state.extra is! ProductModel) {
            return transitionPage(
              state: state,
              child: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          final product = state.extra as ProductModel;
          return transitionPage(
            state: state,
            child: SingleProductScreen(productModel: product),
          );
        },
      ),
      GoRoute(
        path: '/category-screen',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const CategoryScreen(),
        ),
      ),

      GoRoute(
        path: '/order-status',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const OrderStatusScreen(),
        ),
      ),

      GoRoute(
        path: '/product-by-category',
        pageBuilder: (context, state) {
          if (state.extra is! CategoryModel) {
            return transitionPage(
              state: state,
              child: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          final category = state.extra as CategoryModel;
          return transitionPage(
            state: state,
            child: ProductByCategoryScreen(categoryModel: category),
          );
        },
      ),
      GoRoute(
        path: '/favorite-screen',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const FavScreen(),
        ),
      ),
      GoRoute(
        path: '/search-screen',
        pageBuilder: (context, state) {
          final bool isAdmin =
              (state.extra is bool) ? state.extra as bool : false;
          return transitionPage(
            state: state,
            child: SearchScreen(
              isAdmin: isAdmin,
            ),
          );
        },
      ),
      GoRoute(
        path: '/checkout-screen',
        pageBuilder: (context, state) {
          return transitionPage(
            state: state,
            child: const CheckoutScreen(),
          );
        },
      ),
      GoRoute(
        path: '/profile-setup',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const ProfileSetupView(),
        ),
      ),
      GoRoute(
        path: '/adminDashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => transitionPage(
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/webview',
        pageBuilder: (context, state) {
          final String url =
              (state.extra is String) ? state.extra as String : "";
          return transitionPage(
            state: state,
            child: WebviewScreen(url: url),
          );
        },
      ),

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
            if (state.extra is! ProductModel) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
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
            final String productId =
                (state.extra is String) ? state.extra as String : "";
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
          if (state.extra is! OrderModel) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final order = state.extra as OrderModel;
          log(" [Single Order Screen] provider $order");

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

CustomTransitionPage transitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
