import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_listing_screen.dart';
import 'my_listings_screen.dart';
import 'add_new_product_screen.dart';
import 'cart_screen.dart';
import 'previous_purchases_screen.dart';
import 'user_dashboard_screen.dart';
import 'product_detail_screen.dart';

// EcoFinds Color Palette
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
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Add these variables to handle data from navigation
  String userId = 'USER123';
  String selectedLocation = '';
  String enteredAddress = '';

  List<Product> products = [
    Product(
      id: 1,
      title: "Wireless Bluetooth Headphones",
      category: "Electronics",
      price: 99.99,
      description: "High-quality wireless headphones with noise cancellation",
      image: "https://via.placeholder.com/200",
      isOwned: false,
    ),
    Product(
      id: 2,
      title: "Vintage Leather Jacket",
      category: "Fashion",
      price: 149.99,
      description: "Genuine leather jacket in excellent condition",
      image: "https://via.placeholder.com/200",
      isOwned: true,
    ),
    Product(
      id: 3,
      title: "Coffee Table",
      category: "Furniture",
      price: 249.99,
      description: "Modern wooden coffee table, barely used",
      image: "https://via.placeholder.com/200",
      isOwned: false,
    ),
    Product(
      id: 4,
      title: "Gaming Mouse",
      category: "Electronics",
      price: 59.99,
      description: "RGB gaming mouse with programmable buttons",
      image: "https://via.placeholder.com/200",
      isOwned: true,
    ),
  ];

  List<Product> cartItems = [];
  List<Product> purchaseHistory = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments from navigation if available
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      userId = args['userId'] ?? 'USER123';
      selectedLocation = args['selectedLocation'] ?? '';
      enteredAddress = args['enteredAddress'] ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildEcoTheme(),
      child: Scaffold(
        backgroundColor: EcoColors.backgroundWhite,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            ProductListingScreen(
              products: products,
              onAddToCart: _addToCart,
              onProductTap: _viewProductDetails,
            ),
            MyListingsScreen(
              products: products.where((p) => p.isOwned).toList(),
              onEdit: _editProduct,
              onDelete: _deleteProduct,
              onAddNew: () => _navigateToAddProduct(),
            ),
            CartScreen(
              cartItems: cartItems,
              onRemoveFromCart: _removeFromCart,
            ),
            PreviousPurchasesScreen(
              purchases: purchaseHistory,
            ),
            const UserDashboardScreen(),
          ],
        ),
        bottomNavigationBar: _buildEcoBottomNavigationBar(),
        floatingActionButton: _currentIndex == 1 ? _buildEcoFAB() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      appBarTheme: const AppBarTheme(
        backgroundColor: EcoColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: EcoColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        shadowColor: Color(0x1A2E7D32), // EcoColors.primaryGreen.withOpacity(0.1)
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EcoColors.secondaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: EcoColors.textDark,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: EcoColors.textDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: EcoColors.textDark,
        ),
        bodyMedium: TextStyle(
          color: EcoColors.textLight,
        ),
      ),
    );
  }

  Widget _buildEcoBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Reduced horizontal padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Changed from spaceAround to spaceEvenly
            children: [
              Expanded(child: _buildNavItem(0, Icons.eco, 'Explore')),
              Expanded(child: _buildNavItem(1, Icons.inventory_2_outlined, 'My Items')),
              Expanded(child: _buildNavItem(2, Icons.shopping_bag_outlined, 'Cart', 
                badgeCount: cartItems.length)),
              Expanded(child: _buildNavItem(3, Icons.history, 'History')),
              Expanded(child: _buildNavItem(4, Icons.person_outline, 'Profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {int? badgeCount}) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _scaleAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6), // Reduced padding
              decoration: BoxDecoration(
                color: isSelected ? EcoColors.primaryGreen.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16), // Reduced border radius
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? EcoColors.primaryGreen : EcoColors.textLight,
                        size: 22, // Slightly smaller icon
                      ),
                      if (badgeCount != null && badgeCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: EcoColors.errorRed,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14, // Smaller badge
                              minHeight: 14,
                            ),
                            child: Text(
                              badgeCount > 99 ? '99+' : badgeCount.toString(), // Handle large numbers
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9, // Smaller font
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? EcoColors.primaryGreen : EcoColors.textLight,
                        fontSize: 10, // Smaller font size
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, // Handle text overflow
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEcoFAB() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use different FAB styles based on screen width
        if (constraints.maxWidth < 400) {
          // Smaller FAB for smaller screens
          return FloatingActionButton(
            onPressed: _navigateToAddProduct,
            backgroundColor: EcoColors.secondaryGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.add_circle_outline, size: 24),
          );
        } else {
          // Extended FAB for larger screens
          return FloatingActionButton.extended(
            onPressed: _navigateToAddProduct,
            backgroundColor: EcoColors.secondaryGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, size: 20),
                SizedBox(width: 8),
                Text('Add Item'),
              ],
            ),
          );
        }
      },
    );
  }

  void _addToCart(Product product) {
    setState(() {
      cartItems.add(product);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.eco, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.title} added to cart!',
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis, // Handle long product titles
              ),
            ),
          ],
        ),
        backgroundColor: EcoColors.secondaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeFromCart(Product product) {
    setState(() {
      cartItems.remove(product);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.title} removed from cart',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: EcoColors.earthBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _viewProductDetails(Product product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(
          product: product,
          onAddToCart: _addToCart,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AddNewProductScreen(
          onProductAdded: _addProduct,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _addProduct(Product product) {
    setState(() {
      products.add(product);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.eco, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'New eco-friendly item added!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: EcoColors.leafGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewProductScreen(
          product: product,
          onProductAdded: _updateProduct,
        ),
      ),
    );
  }

  void _updateProduct(Product updatedProduct) {
    setState(() {
      int index = products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item updated successfully!'),
        backgroundColor: EcoColors.secondaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _deleteProduct(Product product) {
    setState(() {
      products.removeWhere((p) => p.id == product.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.title} deleted',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: EcoColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              products.add(product);
            });
          },
        ),
      ),
    );
  }
}