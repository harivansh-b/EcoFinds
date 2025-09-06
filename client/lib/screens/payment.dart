import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// EcoFinds Color Palette (matching your main screen)
class EcoColors {
  static const Color primaryGreen = Color(0xFF2E7D32);      // Deep forest green
  static const Color secondaryGreen = Color(0xFF4CAF50);    // Fresh green
  static const Color accentGreen = Color(0xFF81C784);       // Light green
  static const Color earthBrown = Color(0xFF5D4037);        // Earth brown
  static const Color warmBeige = Color(0xFFF1F8E9);         // Warm beige
  static const Color leafGreen = Color(0xFF66BB6A);         // Leaf green
  static const Color skyBlue = Color(0xFF03DAC6);           // Eco teal
  static const Color backgroundWhite = Color(0xFFFAFAFA);   // Soft white
  static const Color textDark = Color(0xFF1B5E20);          // Dark green text
  static const Color textLight = Color(0xFF757575);         // Light grey text
  static const Color cardBackground = Colors.white;
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF2E7D32);
}

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

class _PaymentScreenState extends State<PaymentScreen> with TickerProviderStateMixin {
  late Razorpay _razorpay;
  String paymentStatus = "Preparing payment...";
  bool isLoading = true;
  bool isSuccess = false;
  bool isError = false;
  
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Start payment automatically after the screen renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _startPayment();
    });
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_zk5c0q1Ahl5aqc', // Replace with your live key
      'amount': (widget.totalAmount * 100).toInt(), // Amount in paise
      'currency': 'INR',
      'name': 'EcoFinds Marketplace',
      'description': 'Sustainable shopping for a better tomorrow',
      'prefill': {
        'contact': '9876543210',
        'email': 'test@example.com',
      },
      'theme': {'color': '#2E7D32'}, // Using EcoFinds primary green
    };

    try {
      _razorpay.open(options);
      setState(() {
        paymentStatus = "Opening secure payment gateway...";
        isLoading = true;
        isError = false;
      });
    } catch (e) {
      setState(() {
        paymentStatus = "Error opening payment gateway";
        isLoading = false;
        isError = true;
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      paymentStatus = "Payment completed successfully!";
      isLoading = false;
      isSuccess = true;
      isError = false;
    });
    _pulseController.stop();
    
    // Show success message and navigate back
    Future.delayed(const Duration(seconds: 2), () {
      widget.onPaymentSuccess();
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      paymentStatus = "Payment failed. Please try again.";
      isLoading = false;
      isSuccess = false;
      isError = true;
    });
    _pulseController.stop();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      paymentStatus = "Processing wallet payment...";
      isLoading = true;
      isError = false;
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildEcoTheme(),
      child: Scaffold(
        backgroundColor: EcoColors.backgroundWhite,
        appBar: _buildEcoAppBar(),
        body: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPaymentIcon(),
                        const SizedBox(height: 32),
                        _buildOrderSummaryCard(),
                        const SizedBox(height: 24),
                        _buildStatusCard(),
                      ],
                    ),
                  ),
                  if (isError) _buildRetryButton(),
                  const SizedBox(height: 16),
                  _buildEcoFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _buildEcoTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: EcoColors.primaryGreen,
      scaffoldBackgroundColor: EcoColors.backgroundWhite,
      colorScheme: const ColorScheme.light(
        primary: EcoColors.primaryGreen,
        secondary: EcoColors.secondaryGreen,
        surface: EcoColors.cardBackground,
        background: EcoColors.backgroundWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: EcoColors.textDark,
        onBackground: EcoColors.textDark,
      ),
    );
  }

  PreferredSizeWidget _buildEcoAppBar() {
    return AppBar(
      backgroundColor: EcoColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Secure Payment',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPaymentIcon() {
    if (isSuccess) {
      return Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          color: EcoColors.successGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 60,
        ),
      );
    } else if (isError) {
      return Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          color: EcoColors.errorRed,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 60,
        ),
      );
    } else {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    EcoColors.primaryGreen,
                    EcoColors.secondaryGreen,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: EcoColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.payment,
                color: Colors.white,
                size: 50,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      color: EcoColors.cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              EcoColors.warmBeige,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.eco,
                  color: EcoColors.leafGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: EcoColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items (${widget.cartItems.length})',
                  style: TextStyle(
                    fontSize: 16,
                    color: EcoColors.textLight,
                  ),
                ),
                Text(
                  '₹${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: EcoColors.textDark,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: EcoColors.accentGreen),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: EcoColors.primaryGreen,
                  ),
                ),
                Text(
                  '₹${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: EcoColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor = isSuccess 
        ? EcoColors.successGreen 
        : isError 
            ? EcoColors.errorRed 
            : EcoColors.primaryGreen;
    
    IconData statusIcon = isSuccess 
        ? Icons.check_circle 
        : isError 
            ? Icons.error 
            : Icons.hourglass_empty;

    return Card(
      color: EcoColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                paymentStatus,
                style: TextStyle(
                  fontSize: 16,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EcoColors.secondaryGreen, EcoColors.leafGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: EcoColors.secondaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _startPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Retry Payment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              color: EcoColors.textLight,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Secured by Razorpay',
              style: TextStyle(
                color: EcoColors.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '🌱 Every purchase helps build a sustainable future',
          style: TextStyle(
            color: EcoColors.leafGreen,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}