import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/providers/auth_provider.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();

    if (kDebugMode) {
      emailCtrl.text = "unknowusers420@gmail.com";
      passCtrl.text = "12345678";
      confirmPassCtrl.text = "12345678";
    }
  }

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
                      final auth = context.read<AuthProvider>();

                      if (auth.isLoading) return;

                      // validate inputs...
                      if (passCtrl.text.isEmpty ||
                          emailCtrl.text.isEmpty ||
                          confirmPassCtrl.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "All fields must be filled",
                            backgroundColor: Colors.red);
                        return;
                      }
                      if (!auth.validateEmail(emailCtrl.text)) {
                        Fluttertoast.showToast(
                            msg: "Incorrect Email",
                            backgroundColor: Colors.red);
                        return;
                      }
                      if (!auth.validatePassword(passCtrl.text)) {
                        Fluttertoast.showToast(
                            msg: "Password must be at least 8 characters",
                            backgroundColor: Colors.red);
                        return;
                      }
                      if (passCtrl.text != confirmPassCtrl.text) {
                        Fluttertoast.showToast(
                            msg: "Passwords do not match",
                            backgroundColor: Colors.red);
                        return;
                      }

                      // Show a blocking loader dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(child: SmallLoader()),
                      );

                      try {
                        await auth.signUpWithEmail(
                            emailCtrl.text.trim(), passCtrl.text.trim());

                        // Sign-up succeeded: verification email has been sent and user is signed out.
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(); // dismiss loader

                        Fluttertoast.showToast(
                          msg:
                              "Account created! Verification email sent — check your inbox (or spam).",
                          backgroundColor: Colors.green,
                        );

                        // Navigate explicitly to login
                        // ignore: use_build_context_synchronously
                        if (mounted) context.go('/login');
                      } on firebase.FirebaseAuthException catch (e) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(); // dismiss loader
                        Fluttertoast.showToast(
                            msg: e.message ?? 'Signup failed',
                            backgroundColor: Colors.red);
                      } catch (e) {
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                            msg: 'Unexpected error',
                            backgroundColor: Colors.red);
                      }
                    },
                    child: auth.isLoading == true
                        ? Center(child: SmallLoader())
                        : const Text(
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
