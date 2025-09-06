import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';

// EcoFinds Color Palette (consistent with other screens)
class EcoColors {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF81C784);
  static const Color earthBrown = Color(0xFF5D4037);
  static const Color warmBeige = Color(0xFFF1F8E9);
  static const Color leafGreen = Color(0xFF66BB6A);
  static const Color skyBlue = Color(0xFF03DAC6);
  static const Color backgroundWhite = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF1B5E20);
  static const Color textLight = Color(0xFF757575);
  static const Color cardBackground = Colors.white;
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningOrange = Color(0xFFFF8F00);
}

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;
  final Function(Product) onRemoveFromCart;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onRemoveFromCart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isProcessingOrder = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = widget.cartItems.fold(0, (sum, item) => sum + item.price);
    double deliveryFee = subtotal > 100 ? 0 : 5.99;
    double total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: EcoColors.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: widget.cartItems.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartContent(subtotal, deliveryFee, total),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: EcoColors.primaryGreen,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'My Cart (${widget.cartItems.length})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                EcoColors.primaryGreen,
                EcoColors.secondaryGreen,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: 20,
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 60,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              if (widget.cartItems.isNotEmpty)
                Positioned(
                  bottom: 40,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.eco, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Sustainable shopping awaits!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: EcoColors.warmBeige,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: EcoColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your eco-cart is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: EcoColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Find sustainable items to add!',
              style: TextStyle(
                fontSize: 16,
                color: EcoColors.textLight,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to products tab
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Navigate to Explore tab to start shopping!'),
                      ],
                    ),
                    backgroundColor: EcoColors.skyBlue,
                  ),
                );
              },
              icon: const Icon(Icons.eco),
              label: const Text('Start Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: EcoColors.secondaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(double subtotal, double deliveryFee, double total) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildCartItems(),
        _buildOrderSummary(subtotal, deliveryFee, total),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.cartItems.length,
      itemBuilder: (context, index) {
        Product product = widget.cartItems[index];
        return _buildCartItem(product, index);
      },
    );
  }

  Widget _buildCartItem(Product product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Hero(
              tag: 'product_image_${product.id}',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: EcoColors.warmBeige,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: EcoColors.primaryGreen.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: EcoColors.primaryGreen,
                        size: 32,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: EcoColors.secondaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: EcoColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: EcoColors.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: EcoColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: EcoColors.secondaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            
            // Remove Button
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: EcoColors.errorRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: EcoColors.errorRed,
                      size: 24,
                    ),
                    onPressed: () => _showRemoveConfirmation(context, product),
                  ),
                ),
                const Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 11,
                    color: EcoColors.errorRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double deliveryFee, double total) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: EcoColors.warmBeige,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_long, color: EcoColors.primaryGreen, size: 24),
                SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: EcoColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          
          // Summary Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Items (${widget.cartItems.length})',
                  '\$${subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                
                _buildSummaryRow(
                  'Delivery Fee',
                  deliveryFee == 0 
                      ? 'FREE' 
                      : '\$${deliveryFee.toStringAsFixed(2)}',
                  valueColor: deliveryFee == 0 ? EcoColors.successGreen : null,
                  isFree: deliveryFee == 0,
                ),
                
                if (subtotal < 100 && subtotal > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: EcoColors.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: EcoColors.warningOrange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            color: EcoColors.warningOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Add \$${(100 - subtotal).toStringAsFixed(2)} more for FREE eco-delivery!',
                              style: const TextStyle(
                                fontSize: 13,
                                color: EcoColors.warningOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: EcoColors.accentGreen, thickness: 1),
                ),
                
                _buildSummaryRow(
                  'Total:',
                  '\$${total.toStringAsFixed(2)}',
                  isTotal: true,
                ),
                
                const SizedBox(height: 24),
                
                // Eco Impact Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EcoColors.leafGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: EcoColors.leafGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco, color: EcoColors.leafGreen, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Eco Impact',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: EcoColors.textDark,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'This order saves ~${(widget.cartItems.length * 0.5).toStringAsFixed(1)} kg CO₂',
                              style: const TextStyle(
                                color: EcoColors.leafGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessingOrder ? null : () => _showCheckoutDialog(context, total),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EcoColors.successGreen,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: EcoColors.successGreen.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: _isProcessingOrder
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Processing...', style: TextStyle(fontSize: 16)),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_checkout, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Continue Shopping Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.eco, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Navigate to Explore tab to continue!'),
                            ],
                          ),
                          backgroundColor: EcoColors.skyBlue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Continue Shopping'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: EcoColors.primaryGreen),
                      foregroundColor: EcoColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, 
      {Color? valueColor, bool isTotal = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: EcoColors.textDark,
          ),
        ),
        Row(
          children: [
            if (isFree)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: EcoColors.successGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ECO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 20 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? (isTotal ? EcoColors.successGreen : EcoColors.textDark),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showRemoveConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.remove_shopping_cart_outlined,
            color: EcoColors.errorRed,
            size: 48,
          ),
          title: const Text(
            'Remove Item?',
            style: TextStyle(
              color: EcoColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Remove "${product.title}" from your eco-cart?',
            textAlign: TextAlign.center,
            style: const TextStyle(color: EcoColors.textLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: EcoColors.textLight,
              ),
              child: const Text('Keep Item'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                HapticFeedback.mediumImpact();
                widget.onRemoveFromCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.remove_circle_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${product.title} removed from cart')),
                      ],
                    ),
                    backgroundColor: EcoColors.errorRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EcoColors.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context, double total) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.eco,
            color: EcoColors.successGreen,
            size: 48,
          ),
          title: const Text(
            'Complete Your Order',
            style: TextStyle(
              color: EcoColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: EcoColors.warmBeige,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items:', style: TextStyle(color: EcoColors.textDark)),
                        Text('\$${(total - (total > 100 ? 0 : 5.99)).toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery:', style: TextStyle(color: EcoColors.textDark)),
                        Text(total > 100 ? "FREE" : "\$5.99"),
                      ],
                    ),
                    const Divider(color: EcoColors.primaryGreen),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: EcoColors.textDark,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: EcoColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EcoColors.leafGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: EcoColors.leafGreen.withOpacity(0.3)),
                ),
                child: const Text(
                  '🌱 This is a demo app. In a real app, this would process payment and create your eco-friendly order!',
                  style: TextStyle(
                    fontSize: 12,
                    color: EcoColors.leafGreen,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: EcoColors.textLight,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isProcessingOrder = true;
                });
                
                await Future.delayed(const Duration(seconds: 2));
                
                if (mounted) {
                  setState(() {
                    _isProcessingOrder = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Order placed successfully! 🌱'),
                        ],
                      ),
                      backgroundColor: EcoColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.eco, size: 18),
              label: const Text('Place Eco-Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: EcoColors.successGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}