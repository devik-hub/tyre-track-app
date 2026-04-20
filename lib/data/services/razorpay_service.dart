import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final razorpayServiceProvider = Provider((ref) => RazorpayService());

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) {
      onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onFailure != null) {
      onFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet Selected: ${response.walletName}");
  }

  void openCheckout({
    required double amount,
    required String contact,
    required String email,
    required String description,
  }) {
    // IMPORTANT: Hardcoded Razorpay test key for sandbox testing.
    // Replace with explicit LIVE KEY before configuring for production binary compilation!
    const String testKeyId = 'rzp_test_dummyKeyForBuildingPhase10'; 

    var options = {
      'key': testKeyId,
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
      'name': 'Jagadale Retreads',
      'description': description,
      'timeout': 120, // in seconds
      'prefill': {
        'contact': contact,
        'email': email
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Init Error: $e');
    }
  }

  void dispose() {
    _razorpay.clear(); 
  }
}
