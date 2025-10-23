import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/common_widgets.dart/custom_background.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      // body: CustomBackground(child: Container()),
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: height * 0.015),
              // Centered Image
              Center(
                child: Image.asset(
                  "assets/images/titles/drops_cleaned.png",
                  height: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
