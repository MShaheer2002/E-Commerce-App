import 'package:e_commerce_app/core/providers/provider_setup.dart';
import 'package:e_commerce_app/firebase_options.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/providers/theme_provider.dart';
import 'package:e_commerce_app/routes/GoRoute_routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using Builder ensures we get a context under the MultiProvider tree
    return Builder(
      builder: (cnx) {
        final themeProvider = context.watch<ThemeProvider>();
        final authProvider = context.watch<AuthProvider >();

        return MaterialApp.router(
          title: "E-Commerce App",
          debugShowCheckedModeBanner: false,
          routerConfig: createRouter(authProvider),
          theme: themeProvider.currentTheme,
        );
      },
    );
  }
}
