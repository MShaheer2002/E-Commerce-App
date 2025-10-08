import 'package:e_commerce_app/core/providers/provider_setup.dart';
import 'package:e_commerce_app/presentation/providers/theme_provider.dart';
import 'package:e_commerce_app/presentation/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: AppProvider.all,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: "E-Commerce-App",
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const HomeScreen(),
    );
  }
}
