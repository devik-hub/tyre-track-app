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
    String? orderId,
  }) {
    if (amount <= 0) {
      debugPrint('Razorpay Error: Checkout amount must be greater than zero.');
      return;
    }

    // Configurable via --dart-define=RAZORPAY_KEY=rzp_live_...
    const String defaultTestKey = 'rzp_test_dummyKeyForBuildingPhase10';
    const String apiKey = String.fromEnvironment('RAZORPAY_KEY', defaultValue: defaultTestKey);

    var options = <String, dynamic>{
      'key': apiKey,
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
      'name': 'Jagadale Retreads',
      'description': description,
      'timeout': 120, // in seconds
      'prefill': {
        'contact': contact,
        'email': email,
      },
    };

    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

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
