import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      emailCtrl.text = "unknowusers420@gmail.com";
    }
  }

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
                SizedBox(height: height * 0.06),
                Image.asset("assets/images/productPlug_logo.png"),
                const SizedBox(height: 20),
                const Text(
                  "Enter your email to reset your password",
                  style: TextStyle(
                      color: KprimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.04),
                CustomTextField(
                  hintText: "email@domain.com",
                  controller: emailCtrl,
                  horizontalPadding: width * 0.06,
                ),
                SizedBox(height: height * 0.03),
                Consumer<AuthProvider>(
                  builder: (context, value, child) => CustomButton(
                    horizontalPadding: width * 0.06,
                    onPressed: auth.isLoading
                        ? () {}
                        : () async {
                            if (emailCtrl.text.trim().isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please enter your email",
                                  backgroundColor: Colors.red);
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => Center(
                                child:
                                    SmallLoader(backgroundColor: Colors.white),
                              ),
                            );

                            try {
                              await auth.forgotPassword(emailCtrl.text.trim());
                              if (!mounted) return;
                              Navigator.of(context).pop(); // close loader
                              Fluttertoast.showToast(
                                  msg:
                                      "Password reset email sent! Check your inbox.",
                                  backgroundColor: Colors.green);
                            } catch (e) {
                              if (!mounted) return;
                              Navigator.of(context).pop();
                              Fluttertoast.showToast(
                                  msg: e.toString(),
                                  backgroundColor: Colors.red);
                            }
                          },
                    child: auth.isLoading
                        ? Center(child: SmallLoader())
                        : const Text(
                            "Send Reset Link",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: 'Remembered your password? '),
                      TextSpan(
                        text: 'Login',
                        style: const TextStyle(
                          color: KprimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.go('/login'),
                      ),
                    ],
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
