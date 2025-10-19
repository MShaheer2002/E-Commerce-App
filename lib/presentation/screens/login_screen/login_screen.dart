import 'dart:developer';
import 'dart:io';

import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
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
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final auth = context.read<AuthProvider>();

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
                        if (auth.isLoading) {
                          return;
                        }
                        if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "All fields must be field",
                              backgroundColor: Colors.red);
                          return;
                        } else if (!auth.validateEmail(emailCtrl.text)) {
                          Fluttertoast.showToast(
                              msg: "Invalid Email",
                              backgroundColor: Colors.red);
                          return;
                        }
                        try {
                          await auth.loginWithEmail(
                              emailCtrl.text, passCtrl.text);
                        } on firebase.FirebaseAuthException catch (e) {
                          Fluttertoast.showToast(
                              msg: e.message ?? "something went wrong",
                              backgroundColor: Colors.red);
                        } catch (e) {
                          Fluttertoast.showToast(
                              msg: "somwthing went Wrong",
                              backgroundColor: Colors.red);
                          log("[Sign In with Email Error] $e");
                        }
                      },
                      child: auth.isLoading == true
                          ? Center(
                              child: SmallLoader(),
                            )
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
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: Text(
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
                        await auth.signInWithGoogle();
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
