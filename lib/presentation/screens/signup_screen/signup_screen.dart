import 'dart:developer';

import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
                // App Logo
                Image.asset("assets/images/applogo.png"),

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
                      if (auth.isLoading) {
                        return;
                      }
                      if (passCtrl.text.isEmpty ||
                          emailCtrl.text.isEmpty ||
                          confirmPassCtrl.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "All fields must be field",
                            backgroundColor: Colors.red);
                        return;
                      } else if (!auth.validateEmail(emailCtrl.text)) {
                        Fluttertoast.showToast(
                            msg: "Incorrect Email",
                            backgroundColor: Colors.red);
                        return;
                      } else if (!auth.validatePassword(passCtrl.text)) {
                        Fluttertoast.showToast(
                            msg: "Password must be 8 character long",
                            backgroundColor: Colors.red);
                        return;
                      } else if (passCtrl.text != confirmPassCtrl.text) {
                        Fluttertoast.showToast(
                            msg: "Password Mismatch",
                            backgroundColor: Colors.red);
                        return;
                      } else {
                        try {
                          await auth.signUpWithEmail(
                            emailCtrl.text.trim(),
                            passCtrl.text.trim(),
                          );
                        } on firebase.FirebaseAuthException catch (e) {
                          Fluttertoast.showToast(
                              msg: e.message ?? "something went wrong",
                              backgroundColor: Colors.red);
                        } catch (e) {
                          Fluttertoast.showToast(
                              msg: "somwthing went Wrong",
                              backgroundColor: Colors.red);
                          log("[Sign up Error] $e");
                        }
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
