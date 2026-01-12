import 'dart:developer';
import 'dart:io';

import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/providers/auth_provider.dart';
import 'package:ProductPlug/presentation/providers/profile_setup_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
      emailCtrl.text = "admin@admin.com";
      passCtrl.text = "abc12345678";
      // emailCtrl.text = "unknowusers420@gmail.com";
      // passCtrl.text = "abc123";
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
                  const SizedBox(height: 20),
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
                  SizedBox(height: height * 0.01),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            context.push('/forgot-password');
                          },
                          child: const Text(
                            textAlign: TextAlign.right,
                            "Forgot password?",
                            style: TextStyle(
                                fontSize: 14,
                                color: KprimaryColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
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
                      child: const Text(
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
                        "Don't have an account?",
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
                      if (auth.isLoading == true) {
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(
                            child: SmallLoader(backgroundColor: Colors.white)),
                      );

                      try {
                        await auth.signInWithGoogle(profile);

                        if (!context.mounted) return;
                        Navigator.of(context).pop(); // Close loader

                        final role = await auth.getUserRole();
                        if (role == 'admin') {
                          context.go('/adminDashboard');
                        } else {
                          context.go('/');
                        }
                      } on firebase.FirebaseAuthException catch (e) {
                        if (context.mounted) Navigator.of(context).pop();
                        Fluttertoast.showToast(
                            msg: e.message ?? "Something went wrong");
                        return;
                      } catch (e) {
                        if (context.mounted) Navigator.of(context).pop();
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

                  // ✅ Apple Sign-In Button (iOS only)
                  if (Platform.isIOS)
                    CustomButton(
                      onPressed: () async {
                        if (auth.isLoading == true) {
                          return;
                        }

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => Center(
                              child:
                                  SmallLoader(backgroundColor: Colors.white)),
                        );

                        try {
                          await auth.signInWithApple(profile);

                          if (!context.mounted) return;
                          Navigator.of(context).pop(); // Close loader

                          final role = await auth.getUserRole();
                          if (role == 'admin') {
                            context.go('/adminDashboard');
                          } else {
                            context.go('/');
                          }
                        } on firebase.FirebaseAuthException catch (e) {
                          if (context.mounted) Navigator.of(context).pop();
                          Fluttertoast.showToast(
                              msg: e.message ?? "Something went wrong");
                          return;
                        } catch (e) {
                          if (context.mounted) Navigator.of(context).pop();
                          log("[Apple Sign in Error] $e");
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

                  if (Platform.isIOS) SizedBox(height: height * 0.02),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      children: [
                        const TextSpan(
                          text: 'By clicking continue, you agree to our ',
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            color: KprimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              log('Terms of Service tapped');
                              context.push("/webview",
                                  extra:
                                      "https://shaheerprojectsflutter.github.io/productplug-legal/terms_and_condition.html");
                            },
                        ),
                        const TextSpan(
                          text: ' and ',
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: KprimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              log('Privacy Policy tapped');
                              context.push("/webview",
                                  extra:
                                      "https://shaheerprojectsflutter.github.io/productplug-legal/privacy_policy.html");
                            },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
