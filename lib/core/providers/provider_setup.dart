// lib/core/providers/provider_setup.dart
import 'package:e_commerce_app/core/providers/admin/productManagement_provider.dart';
import 'package:e_commerce_app/core/providers/admin/userManagement_provider.dart';
import 'package:e_commerce_app/core/providers/cart_provider.dart';
import 'package:e_commerce_app/core/providers/category_provider.dart';
import 'package:e_commerce_app/core/providers/fav_provider.dart';
import 'package:e_commerce_app/core/providers/handle_unautharized_access_provider.dart';
import 'package:e_commerce_app/core/providers/notification_provider.dart';
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
    ChangeNotifierProxyProvider<HandleUnauthorizedAccessProvider,
        FavoriteService>(
      create: (context) =>
          FavoriteService(context.read<HandleUnauthorizedAccessProvider>()),
      update: (context, authGuard, previous) =>
          previous ?? FavoriteService(authGuard),
    ),
    ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),
    ChangeNotifierProvider<CartProvider>(
        create: (_) => CartProvider()..setUser()),
    ChangeNotifierProvider<ProfileSetupProvider>(
        create: (context) => ProfileSetupProvider()),
    ChangeNotifierProvider<CacheProvider>(create: (_) => CacheProvider()),
    ChangeNotifierProvider<NotificationProvider>(
        create: (context) => NotificationProvider()),

    // -----------------------Admin------------------------
    ChangeNotifierProvider<UserManagementProvider>(
        create: (context) => UserManagementProvider()),
    ChangeNotifierProvider<ProductmanagementProvider>(
        create: (context) => ProductmanagementProvider()),
  ];
}
