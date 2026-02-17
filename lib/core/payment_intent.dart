import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

/// In production, always create payment intents on your backend server.
Future<Map<String, String>> createPaymentIntent(
    double amount, String userEmail) async {
  final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
  final secretKey = dotenv.env['STRIPE_SECRET_KEY'];

  if (secretKey == null || secretKey.isEmpty) {
    throw Exception('STRIPE_SECRET_KEY not found in .env file');
  }

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {
        'amount': (amount * 100).toInt().toString(), // Convert dollars → cents
        'currency': 'usd',
        'payment_method_types[]': 'card',
        if (userEmail != null && userEmail.trim().isNotEmpty)
          'receipt_email': userEmail,
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to create payment intent: ${body['error']?['message'] ?? 'Unknown error'}",
      );
    }

    final clientSecret = body['client_secret'];
    final paymentIntentId = body['id'];

    if (clientSecret == null || paymentIntentId == null) {
      throw Exception(
          'Invalid response from Stripe when creating PaymentIntent.');
    }

    log('[Stripe] PaymentIntent created: $paymentIntentId');
    return {
      'clientSecret': clientSecret,
      'paymentIntentId': paymentIntentId,
    };
  } catch (e) {
    log('Error creating paym, String currUserEmailent intent: $e');
    rethrow;
  }
}

/// 💳 Shows Stripe's Payment Sheet UI
Future<String> showPaymentSheet(double amount, String userEmail) async {
  try {
    log('[Checkout] Creating PaymentIntent for \$${amount.toStringAsFixed(2)}');

    // Create the payment intent
    final intentData = await createPaymentIntent(amount, userEmail);
    final clientSecret = intentData['clientSecret']!;
    final paymentIntentId = intentData['paymentIntentId']!;
    log('[Checkout] PaymentIntent ID: $paymentIntentId');

    // Initialize the payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'My E-Commerce Store',
        style: ThemeMode.system,
        appearance: PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: const Color(0xFF6C63FF),

            // Light Mode
            background: Brightness.light ==
                    WidgetsBinding
                        .instance.platformDispatcher.platformBrightness
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF1E1E1E),

            componentBackground: Brightness.light ==
                    WidgetsBinding
                        .instance.platformDispatcher.platformBrightness
                ? const Color(0xFFF5F5F5)
                : const Color(0xFF2D2D2D),
          ),
        ),
        allowsDelayedPaymentMethods: true,
      ),
    );

    log('[Checkout] Payment sheet initialized');

    // Show the payment sheet
    await Stripe.instance.presentPaymentSheet();
    log('[Checkout] ✅ Payment successful for intent: $paymentIntentId');

    // You can store the paymentIntentId in Firestore if you want to verify later
    // Example:

    // await FirebaseFirestore.instance.collection('orders').doc(paymentIntentId).set({...});

    return paymentIntentId;
  } on StripeException catch (e) {
    log('Stripe error: ${e.error.message}');
    if (e.error.code == FailureCode.Canceled) {
      throw Exception('Payment cancelled by user');
    }
    throw Exception(e.error.message ?? 'Payment failed');
  } catch (e) {
    log('Payment error: $e');
    rethrow;
  }
}
