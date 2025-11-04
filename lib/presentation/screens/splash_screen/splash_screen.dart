import 'dart:async';

import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2)); 
    // ignore: use_build_context_synchronously
    final authProvider = context.read<AuthProvider>();

    if (mounted) {
      if (authProvider.isLoggedIn) {
        context.go('/'); // home
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Background(
        child: Center(
          child: Image.asset(
            'assets/images/applogo.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
