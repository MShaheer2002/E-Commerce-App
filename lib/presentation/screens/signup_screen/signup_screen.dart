import 'dart:developer';

import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final auth = context.read<AuthProvider>();

    if (kDebugMode) {
      emailCtrl.text = "m.shaheershahid12@gmail.com";
      passCtrl.text = "12345678";
      confirmPassCtrl.text = "12345678";
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // prevents background squeeze
      body: Background(
        showBackButton: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.04),
                // App Logo
                Image.asset("assets/images/productPlug_logo.png"),

                const Text(
                  "Create an account",
                  style: TextStyle(
                    color: KprimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Enter your details to sign up for this app",
                  style: TextStyle(
                    color: KprimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: height * 0.03),

                // Email
                CustomTextField(
                  hintText: "email@domain.com",
                  controller: emailCtrl,
                  horizontalPadding: width * 0.06,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: height * 0.02),

                // Password
                CustomTextField(
                  hintText: "Password",
                  controller: passCtrl,
                  horizontalPadding: width * 0.06,
                  isPassword: true,
                ),
                SizedBox(height: height * 0.02),

                // Confirm Password
                CustomTextField(
                  hintText: "Confirm Password",
                  controller: confirmPassCtrl,
                  horizontalPadding: width * 0.06,
                  isPassword: true,
                ),
                SizedBox(height: height * 0.03),

                // Continue button
                Consumer<AuthProvider>(
                  builder: (context, value, child) => CustomButton(
                    horizontalPadding: width * 0.06,
                    onPressed: () async {
                      log("[Email] ${emailCtrl.text}");
                      if (auth.isLoading) return;

                      if (passCtrl.text.isEmpty ||
                          emailCtrl.text.isEmpty ||
                          confirmPassCtrl.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "All fields must be filled",
                            backgroundColor: Colors.red);
                        return;
                      } else if (!auth.validateEmail(emailCtrl.text)) {
                        Fluttertoast.showToast(
                            msg: "Incorrect Email",
                            backgroundColor: Colors.red);
                        return;
                      } else if (!auth.validatePassword(passCtrl.text)) {
                        Fluttertoast.showToast(
                            msg: "Password must be at least 8 characters",
                            backgroundColor: Colors.red);
                        return;
                      } else if (passCtrl.text != confirmPassCtrl.text) {
                        Fluttertoast.showToast(
                            msg: "Passwords do not match",
                            backgroundColor: Colors.red);
                        return;
                      }

                      try {
                        await auth.signUpWithEmail(
                            emailCtrl.text.trim(), passCtrl.text.trim());

                        // ✅ If sign-up was successful:
                        Fluttertoast.showToast(
                          msg:
                              "Account created! Please check your email for verification.",
                          backgroundColor: Colors.green,
                        );

                        // ✅ Navigate to login
                        if (mounted) context.go('/login');
                      } on firebase.FirebaseAuthException catch (e) {
                        Fluttertoast.showToast(
                          msg: e.message ?? "Something went wrong",
                          backgroundColor: Colors.red,
                        );
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: "Something went wrong",
                          backgroundColor: Colors.red,
                        );
                        log("[Sign up Error] $e");
                      }
                    },
                    child: auth.isLoading == true
                        ? Center(child: SmallLoader())
                        : Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
