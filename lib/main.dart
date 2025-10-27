import 'package:e_commerce_app/core/providers/notification_provider.dart';
import 'package:e_commerce_app/core/providers/provider_setup.dart';
import 'package:e_commerce_app/firebase_options.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/providers/theme_provider.dart';
import 'package:e_commerce_app/routes/GoRoute_routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");
  // Stripe.publishableKey = "pk_test_51SKkGKIx5HBFdIuYOeBnkjsfSRhTZ8bsgTCkgXtN5wtp6jauZVCznPsxamVgBrfD7osuMZtkVD41HLfpVQx0hxys00Lsgvc1mW";
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register all providers globally
  runApp(
    MultiProvider(
      providers: AppProvider.all,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = createRouter(authProvider);

       // Initialize notifications here
    final notificationProvider = context.read<NotificationProvider>();
    notificationProvider.initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: "E-Commerce App",
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: themeProvider.currentTheme,
    );
  }
}
