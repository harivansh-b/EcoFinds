import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;
  final String customerId;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
    required this.customerId,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  String paymentStatus = "Preparing payment...";

  @override
  void initState() {
    super.initState();

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Start payment automatically after the screen renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPayment();
    });
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_zk5c0q1Ahl5aqc', // Replace with your live key
      'amount': (widget.totalAmount * 100).toInt(), // Amount in paise
      'currency': 'INR',
      'name': 'SavorGo Food Delivery',
      'description': 'Payment for your order',
      'prefill': {
        'contact': '9876543210',
        'email': 'test@example.com',
      },
      'theme': {'color': '#F37254'},
    };

    try {
      _razorpay.open(options);
      setState(() {
        paymentStatus = "💳 Payment screen opened";
      });
    } catch (e) {
      setState(() {
        paymentStatus = "❌ Error opening Razorpay: $e";
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      paymentStatus = "✅ Payment Successful: ${response.paymentId}";
    });
    widget.onPaymentSuccess(); // Callback to notify success
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      paymentStatus =
          "❌ Payment Failed: ${response.code} - ${response.message}";
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      paymentStatus = "💼 Wallet Used: ${response.walletName}";
    });
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear Razorpay listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: isDarkMode ? Colors.black : Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              paymentStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _startPayment,
              child: const Text("Retry Payment"),
            ),
            const SizedBox(height: 20),
            Text(
              "Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}