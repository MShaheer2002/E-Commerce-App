import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ⚠️ WARNING: This approach exposes your secret key in the app.
/// In production, you should create payment intents from your backend server.
/// This is only for testing/development purposes.
Future<String> createPaymentIntent(double amount) async {
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
        'amount': (amount * 100).toInt().toString(), // Convert to cents
        'currency': 'usd',
        'payment_method_types[]': 'card',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to create payment intent: ${body['error']?['message'] ?? 'Unknown error'}");
    }

    return body['client_secret'];
  } catch (e) {
    print('Error creating payment intent: $e');
    rethrow;
  }
}

/// Shows Stripe's payment sheet UI for card entry
Future<void> showPaymentSheet(double amount) async {
  try {
    print('Creating payment intent for amount: \$$amount');

    // 1. Create payment intent
    final clientSecret = await createPaymentIntent(amount);
    print('Payment intent created successfully');

    // 2. Initialize payment sheet with card details form
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'My E-Commerce Store',
        style: ThemeMode.system, // Matches your app theme
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFF6C63FF), // Your KprimaryColor
            background: Color(0xFF1E1E1E),
            componentBackground: Color(0xFF2D2D2D),
          ),
        ),
        // Enable customer to save card for future use (optional)
        allowsDelayedPaymentMethods: true,
      ),
    );
    print('Payment sheet initialized');

    // 3. Present payment sheet with card entry form
    await Stripe.instance.presentPaymentSheet();
    print("Payment successful!");
  } on StripeException catch (e) {
    print("Stripe error: ${e.error.message}");

    // Handle user cancellation
    if (e.error.code == FailureCode.Canceled) {
      throw Exception('Payment cancelled by user');
    }

    // Handle other Stripe errors
    throw Exception(e.error.message ?? 'Payment failed');
  } catch (e) {
    print("Payment error: $e");
    rethrow;
  }
}

/// Alternative: Show payment sheet with customization
Future<void> showCustomPaymentSheet(
  double amount, {
  String? customerEmail,
  String? customerName,
}) async {
  try {
    print('Creating payment intent for amount: \$$amount');

    final clientSecret = await createPaymentIntent(amount);
    print('Payment intent created successfully');

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'My E-Commerce Store',
        customerId: null, // Add if you have customer IDs
        customerEphemeralKeySecret: null, // Add if you have ephemeral keys
        style: ThemeMode.dark,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFF6C63FF),
            background: Color(0xFF1E1E1E),
            componentBackground: Color(0xFF2D2D2D),
            componentBorder: Color(0xFF3D3D3D),
            primaryText: Color(0xFFFFFFFF),
            secondaryText: Color(0xFFB0B0B0),
            componentText: Color(0xFFFFFFFF),
            placeholderText: Color(0xFF808080),
          ),
          shapes: PaymentSheetShape(
            borderRadius: 12,
            borderWidth: 1,
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xFF6C63FF),
                text: Color(0xFFFFFFFF),
                border: Color(0xFF6C63FF),
              ),
              dark: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xFF6C63FF),
                text: Color(0xFFFFFFFF),
                border: Color(0xFF6C63FF),
              ),
            ),
            shapes: PaymentSheetPrimaryButtonShape(borderWidth: 12),
          ),
        ),
        billingDetailsCollectionConfiguration:
            const BillingDetailsCollectionConfiguration(
          name: CollectionMode.always,
          email: CollectionMode.always,
          phone: CollectionMode.automatic,
          address: AddressCollectionMode.automatic,
        ),
        // applePay: const PaymentSheetApplePay(
        //   merchantCountryCode: 'US',
        // ),
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'US',
          testEnv: true,
          currencyCode: 'USD',
        ),
      ),
    );

    await Stripe.instance.presentPaymentSheet();
    print("Payment successful!");
  } on StripeException catch (e) {
    print("Stripe error: ${e.error.message}");
    if (e.error.code == FailureCode.Canceled) {
      throw Exception('Payment cancelled by user');
    }
    throw Exception(e.error.message ?? 'Payment failed');
  } catch (e) {
    print("Payment error: $e");
    rethrow;
  }
}
