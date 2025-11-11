// lib/core/providers/provider_setup.dart
import 'package:e_commerce_app/core/providers/admin/analytics_provider.dart';
import 'package:e_commerce_app/core/providers/admin/categoryManagement_provider.dart';
import 'package:e_commerce_app/core/providers/admin/cloudinary_provider.dart';
import 'package:e_commerce_app/core/providers/admin/global_analytics_provider.dart';
import 'package:e_commerce_app/core/providers/admin/productManagement_provider.dart';
import 'package:e_commerce_app/core/providers/admin/settings_provider.dart';
import 'package:e_commerce_app/core/providers/admin/userManagement_provider.dart';
import 'package:e_commerce_app/core/providers/cart_provider.dart';
import 'package:e_commerce_app/core/providers/category_provider.dart';
import 'package:e_commerce_app/core/providers/checkout_provider.dart';
import 'package:e_commerce_app/core/providers/fav_provider.dart';
import 'package:e_commerce_app/core/providers/handle_unautharized_access_provider.dart';
import 'package:e_commerce_app/core/providers/notification_provider.dart';
import 'package:e_commerce_app/core/providers/product_analytics_provider.dart';
import 'package:e_commerce_app/core/providers/product_provider.dart';
import 'package:e_commerce_app/core/providers/search_provider.dart';
import 'package:e_commerce_app/core/providers/single_product_provider.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/providers/cache_provider.dart';
import 'package:e_commerce_app/presentation/providers/profile_setup_provider.dart';
import 'package:e_commerce_app/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProvider {
  static final List<SingleChildWidget> all = [
    ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),
    ChangeNotifierProvider<CategoryProvider>(create: (_) => CategoryProvider()),
    ChangeNotifierProvider<SingleProductProvider>(
        create: (_) => SingleProductProvider()),
    ChangeNotifierProvider(create: (_) => HandleUnauthorizedAccessProvider()),

    ChangeNotifierProvider(create: (_) => ProductAnalyticsProvider()),

    ChangeNotifierProxyProvider2<HandleUnauthorizedAccessProvider,
        ProductAnalyticsProvider, FavoriteService>(
      create: (context) => FavoriteService(
          context.read<HandleUnauthorizedAccessProvider>(),
          context.read<ProductAnalyticsProvider>()),
      update: (context, authGuard, analytics, previous) =>
          previous ?? FavoriteService(authGuard, analytics),
    ),

    ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),
    ChangeNotifierProxyProvider<ProductAnalyticsProvider, CartProvider>(
      create: (context) =>
          CartProvider(context.read<ProductAnalyticsProvider>())..setUser(),
      update: (context, analytics, previous) {
        return previous ?? CartProvider(analytics);
      },
    ),
    ChangeNotifierProvider<ProfileSetupProvider>(
        create: (context) => ProfileSetupProvider()),
    ChangeNotifierProvider<CacheProvider>(create: (_) => CacheProvider()),
    ChangeNotifierProvider<NotificationProvider>(
        create: (context) => NotificationProvider()),

    // -----------------------Admin------------------------
    ChangeNotifierProvider<UserManagementProvider>(
        create: (context) => UserManagementProvider()),
    ChangeNotifierProxyProvider<ProductAnalyticsProvider,
        ProductmanagementProvider>(
      create: (context) =>
          ProductmanagementProvider(context.read<ProductAnalyticsProvider>()),
      update: (context, analyticsProvider, previous) {
        return previous ?? ProductmanagementProvider(analyticsProvider);
      },
    ),

    ChangeNotifierProxyProvider2<HandleUnauthorizedAccessProvider,
        ProductAnalyticsProvider, CheckoutProvider>(
      create: (context) => CheckoutProvider(
          context.read<HandleUnauthorizedAccessProvider>(),
          context.read<ProductAnalyticsProvider>()),
      update: (context, authGuard, analytics, previous) =>
          previous ?? CheckoutProvider(authGuard, analytics),
    ),

    ChangeNotifierProvider<CloudinaryProvider>(
        create: (_) => CloudinaryProvider()),

    ChangeNotifierProvider<AnalyticsProvider>(
        create: (_) => AnalyticsProvider()),

    ChangeNotifierProvider<GlobalAnalyticsProvider>(
        create: (_) => GlobalAnalyticsProvider()),

    ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
    ChangeNotifierProvider<CategorymanagementProvider>(
        create: (_) => CategorymanagementProvider()),
  ];
}
