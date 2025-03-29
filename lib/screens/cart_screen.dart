import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';
import '../utils/colors.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  final String projectId;

  const CartScreen({required this.project, required this.projectId, super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<Map<String, dynamic>> _createRazorpayOrder(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    final response = await http.post(
      Uri.parse('http://your-backend-url:3000/create-razorpay-order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'amount': amount}),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200 || !responseBody['success']) {
      throw Exception(responseBody['error'] ?? 'Failed to create Razorpay order');
    }

    return responseBody['data'];
  }

  void _openCheckout() async {
    try {
      final orderData = await _createRazorpayOrder(widget.project['price']);
      final user = FirebaseAuth.instance.currentUser;

      final options = {
        'key': orderData['keyId'],
        'amount': orderData['amount'],
        'currency': orderData['currency'],
        'order_id': orderData['orderId'],
        'name': 'Bitsphere',
        'description': 'Payment for ${widget.project['name']}',
        'prefill': {
          'email': user?.email,
          'contact': user?.phoneNumber ?? '',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('API not added')) {
        errorMessage = 'Payment service is not available at the moment. Please try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating payment: $errorMessage')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final verifyResponse = await http.post(
        Uri.parse('http://your-backend-url:3000/verify-razorpay-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
        }),
      );

      final verifyBody = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 200 && verifyBody['success']) {
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('services')
              .add({
            'projectId': widget.projectId,
            'projectName': widget.project['name'],
            'addedAt': FieldValue.serverTimestamp(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful! Added to My Services.')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(verifyBody['error'] ?? 'Payment verification failed');
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('API not added')) {
        errorMessage = 'Payment service is not available at the moment. Please try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying payment: $errorMessage')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.project['name'],
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ₹${widget.project['price']}', // Assuming INR
              style: const TextStyle(color: AppColors.accentYellow),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openCheckout,
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}