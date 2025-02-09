import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StripePaymentService {
  final String paymentIntentUrl;

  StripePaymentService({required this.paymentIntentUrl});

  Future<void> initiatePayment({
    required BuildContext context,
    required double amount,
    required Map<String, dynamic> shipping,
    required BillingDetails billingDetails,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(paymentIntentUrl),
        body: json.encode({
          'amount': amount.toInt(),
          'shipping': shipping,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent');
      }

      final jsonResponse = json.decode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Sneakbay',
          style: ThemeMode.light,
          primaryButtonLabel: 'Pay Now',
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'MY',
            currencyCode: 'myr',
            testEnv: true,
          ),
          billingDetails: billingDetails,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blue,
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
      print('Error: $e');
      onFailure();
    }
  }
}

// Singleton instance
final stripePaymentService = StripePaymentService(
  paymentIntentUrl: 'http://192.168.68.114:3000/create-payment-intent',
);
