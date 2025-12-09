import 'dart:async';
import 'dart:developer';

import 'package:e_commerce_app/core/providers/notification_provider.dart';
import 'package:e_commerce_app/core/providers/provider_setup.dart';
import 'package:e_commerce_app/firebase_options.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/providers/theme_provider.dart';
import 'package:e_commerce_app/routes/GoRoute_routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('Background message: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load .env
  await dotenv.load(fileName: ".env");

  // Stripe key
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  // ✅ Background message handler must be set BEFORE Firebase.initializeApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Initialize NotificationProvider (permissions, token, channels, etc.)
  final notificationProvider = NotificationProvider();
  await notificationProvider.initNotifications();

  // ✅ Launch the app
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
