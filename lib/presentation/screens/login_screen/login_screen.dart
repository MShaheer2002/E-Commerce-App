import 'dart:developer';
import 'dart:io';

import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/providers/profile_setup_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      // emailCtrl.text = "admin@admin.com";
      // passCtrl.text = "abc12345678";
      emailCtrl.text = "unknowusers420@gmail.com";
      passCtrl.text = "12345678";
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileSetupProvider>();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Background(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  SizedBox(height: height * 0.04),
                  Image.asset("assets/images/productPlug_logo.png"),
                  const Text(
                    "Enter your email to sign up for this app",
                    style: TextStyle(
                        color: KprimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: height * 0.02),
                  CustomTextField(
                    hintText: "email@domain.com",
                    controller: emailCtrl,
                    horizontalPadding: width * 0.06,
                  ),
                  SizedBox(height: height * 0.02),
                  CustomTextField(
                    hintText: "Password",
                    controller: passCtrl,
                    horizontalPadding: width * 0.06,
                    isPassword: true,
                  ),
                  SizedBox(height: height * 0.02),
                  Consumer<AuthProvider>(
                    builder: (context, value, child) => CustomButton(
                      horizontalPadding: width * 0.06,
                      onPressed: () async {
                        final auth = context.read<AuthProvider>();
                        if (auth.isLoading) return;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => Center(
                              child: Center(
                                  child: SmallLoader(
                                      backgroundColor: Colors.white))),
                        );
                        try {
                          await auth.loginWithEmail(
                            emailCtrl.text.trim(),
                            passCtrl.text.trim(),
                            profile,
                          );
                          final role = await auth.getUserRole();

                          if (!mounted) return; // ✅ check before using context
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop(); // close loader safely
                          if (role == 'admin') {
                            Fluttertoast.showToast(msg: "Welcome, Admin!");
                            Future.microtask(
                                // ignore: use_build_context_synchronously
                                () => context.go('/adminDashboard'));
                          } else {
                            Fluttertoast.showToast(msg: "Welcome back!");
                            // ignore: use_build_context_synchronously
                            context.go('/');
                          } // go to home
                        } on firebase.FirebaseAuthException catch (e) {
                          if (!mounted) return; // ✅ safe again
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop(); // close loader
                          Fluttertoast.showToast(
                            msg: e.message ?? 'Login failed',
                            backgroundColor: Colors.red,
                          );
                        } catch (e) {
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                            msg: 'Unexpected error occurred',
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      child: auth.isLoading == true
                          ? Center(
                              child: SmallLoader(),
                            )
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
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don’t have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: const Text(
                          " Sign up",
                          style: TextStyle(
                              color: KprimaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left line
                      Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: width * 0.06),
                          height: 1,
                          color: KprimaryColor,
                        ),
                      ),

                      // "or" text
                      const Text(
                        "or",
                        style: TextStyle(
                          color: KprimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Right line
                      Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: width * 0.06),
                          height: 1,
                          color: KprimaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  CustomButton(
                    onPressed: () async {
                      try {
                        if (auth.isLoading == true) {
                          return;
                        }
                        await auth.signInWithGoogle(profile);
                      } on firebase.FirebaseAuthException catch (e) {
                        Fluttertoast.showToast(
                            msg: e.message ?? "Something went wrong");
                        return;
                      } catch (e) {
                        log("[Google Sign in Errror] $e");
                        Fluttertoast.showToast(msg: "Something went wrong");
                        return;
                      }
                    },
                    backgroundColor: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svgs/google.svg",
                          height: 25,
                        ),
                        SizedBox(width: width * 0.02),
                        const Text(
                          "Continue with Google",
                          style: TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  CustomButton(
                    onPressed: () async {
                      try {
                        if (Platform.isAndroid) {
                          Fluttertoast.showToast(
                              msg: "This is not avaible for Android",
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        } else {
                          await auth.signInWithApple();
                        }
                      } on firebase.FirebaseAuthException catch (e) {
                        Fluttertoast.showToast(
                            msg: e.message ?? "Something went wrong");
                        return;
                      } catch (e) {
                        log("[Google Sign in Errror] $e");
                        Fluttertoast.showToast(msg: "Something went wrong");
                        return;
                      }
                    },
                    backgroundColor: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svgs/apple.svg",
                          height: 30,
                        ),
                        SizedBox(width: width * 0.02),
                        const Text(
                          "Continue with Apple",
                          style: TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                ],
              ),
            ),
          ),
        )
        // body: Background(
        // child: Padding(
        //   padding: const EdgeInsets.all(16),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       TextField(
        //         controller: emailCtrl,
        //         decoration: const InputDecoration(labelText: 'Email'),
        //       ),
        //       TextField(
        //         controller: passCtrl,
        //         decoration: const InputDecoration(labelText: 'Password'),
        //         obscureText: true,
        //       ),
        //       const SizedBox(height: 16),

        //       // Email/Password login
        //       ElevatedButton(
        //         onPressed: () async {
        //           try {
        //             await auth.loginWithEmail(
        //               emailCtrl.text.trim(),
        //               passCtrl.text.trim(),
        //             );
        //           } catch (e) {
        //             ScaffoldMessenger.of(context).showSnackBar(
        //               SnackBar(content: Text(e.toString())),
        //             );
        //           }
        //         },
        //         child: const Text('Login'),
        //       ),

        //       const SizedBox(height: 12),

        //       // Google Sign-In button
        //       ElevatedButton.icon(
        //         onPressed: () async {
        //           try {
        //             await auth.signInWithGoogle();
        //           } catch (e) {
        //             log("[Sign in Errror] $e");
        //             ScaffoldMessenger.of(context).showSnackBar(
        //               SnackBar(content: Text(e.toString())),
        //             );
        //           }
        //         },
        //         icon: SvgPicture.asset(
        //           'assets/svgs/google.svg', // 👈 add this 48x48 image in assets
        //           height: 24,
        //           width: 24,
        //         ),
        //         label: const Text('Sign in with Google'),
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.white,
        //           foregroundColor: Colors.black87,
        //           minimumSize: const Size(double.infinity, 48),
        //           side: const BorderSide(color: Colors.grey),
        //         ),
        //       ),

        //       const SizedBox(height: 16),

        //       TextButton(
        //         onPressed: () => context.go('/signup'),
        //         child: const Text("Don't have an account? Sign Up"),
        //       ),
        //     ],
        //   ),
        // ),

        // ),
        );
  }
}
