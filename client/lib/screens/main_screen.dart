import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import 'product_listing_screen.dart';
import 'my_listings_screen.dart';
import 'add_new_product_screen.dart';
import 'cart_screen.dart';
import 'previous_purchases_screen.dart';
import 'user_dashboard_screen.dart';
import 'product_detail_screen.dart';

import 'package:eco_finds/env.dart';

final String myurl = ApiConfig.baseUrl;
const String apiKey = "auth_api@12!_23";

// User model to match your backend
class UserData {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      location: json['location'],
      latitude: json['latitude'] != null 
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

// User Service for API calls
class UserService {
  static Future<UserData?> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$myurl/user/getuser/$userId"),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey,
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return UserData.fromJson(userData);
      } else if (response.statusCode == 404) {
        throw Exception("User not found");
      } else if (response.statusCode == 403) {
        throw Exception("Unauthorized access - Invalid API key");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? "Failed to fetch user data");
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Network error - Please check your internet connection");
    }
  }

  static Future<UserData> updateUser(UserData userData) async {
    try {
      final response = await http.patch(
        Uri.parse("$myurl/user/updateuser"),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey,
        },
        body: jsonEncode({
          "id": userData.id,
          "name": userData.name,
          "email": userData.email,
          "phone": userData.phone,
          "location": userData.location,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return UserData.fromJson(result['user']);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? "Failed to update user");
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Network error - Please check your internet connection");
    }
  }
}

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
  final String userId; // Make userId required
  
  const MainScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // User data variables
  String? userName;
  String? userEmail;
  String? userPhone;
  
  // Current user data from API
  UserData? currentUser;
  bool isLoadingUser = false;
  String? userLoadError;

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
    
    // Load user data immediately when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get any additional arguments from navigation
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final String? newUserName = args['userName'];
      final String? newUserEmail = args['userEmail'];
      final String? newUserPhone = args['userPhone'];
      
      // Update cached user info if provided
      setState(() {
        if (newUserName != null) userName = newUserName;
        if (newUserEmail != null) userEmail = newUserEmail;
        if (newUserPhone != null) userPhone = newUserPhone;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Load complete user data from API
  Future<void> _loadUserData() async {
    if (widget.userId.isEmpty) {
      setState(() {
        userLoadError = "User ID is required";
      });
      return;
    }

    setState(() {
      isLoadingUser = true;
      userLoadError = null;
    });

    try {
      final userData = await UserService.getUser(widget.userId);
      if (mounted) {
        setState(() {
          currentUser = userData;
          isLoadingUser = false;
          userLoadError = null;
          
          // Update cached user info
          if (userData != null) {
            userName = userData.name;
            userEmail = userData.email;
            userPhone = userData.phone;
          }
        });
        
        if (userData != null) {
          _showSnackBar("Welcome back, ${userData.name}!");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingUser = false;
          userLoadError = e.toString().replaceAll('Exception: ', '');
        });
        
        // Show error but don't block the user experience
        _showSnackBar(
          "Could not load user data. Using cached information.", 
          isError: true
        );
      }
    }
  }

  // Refresh user data
  Future<void> _refreshUserData() async {
    await _loadUserData();
  }

  // Get current userId - always returns the required userId
  String get currentUserId => widget.userId;

  @override
  Widget build(BuildContext context) {
    // Show loading screen if user data is being loaded for the first time
    if (isLoadingUser && currentUser == null) {
      return Theme(
        data: _buildEcoTheme(),
        child: Scaffold(
          backgroundColor: EcoColors.backgroundWhite,
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: EcoColors.primaryGreen,
                ),
                SizedBox(height: 16),
                Text(
                  "Loading your eco-friendly profile...",
                  style: TextStyle(
                    color: EcoColors.textDark,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error screen if userId is missing or invalid
    if (userLoadError != null && currentUser == null && currentUserId.isEmpty) {
      return Theme(
        data: _buildEcoTheme(),
        child: Scaffold(
          backgroundColor: EcoColors.backgroundWhite,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: EcoColors.errorRed,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "Unable to load user profile",
                  style: TextStyle(
                    color: EcoColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userLoadError ?? "User ID is required",
                  style: TextStyle(
                    color: EcoColors.textLight,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadUserData,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
             // currentUser: currentUser,
              //userId: currentUserId,
            ),
            MyListingsScreen(
              products: products.where((p) => p.isOwned).toList(),
              onEdit: _editProduct,
              onDelete: _deleteProduct,
              onAddNew: () => _navigateToAddProduct(),
              //currentUser: currentUser,
             // userId: currentUserId,
            ),
            CartScreen(
              cartItems: cartItems,
              onRemoveFromCart: _removeFromCart,
              //currentUser: currentUser,
              //userId: currentUserId,
            ),
            PreviousPurchasesScreen(
              purchases: purchaseHistory,
              //currentUser: currentUser,
              //userId: currentUserId,
            ),
            UserDashboardScreen(
              userId: currentUserId,
              //currentUser: currentUser,
            )
          ],
        ),
        bottomNavigationBar: _buildEcoBottomNavigationBar(),
        floatingActionButton: _currentIndex == 1 ? _buildEcoFAB() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // Update user data
  Future<void> _updateUserData(UserData updatedUser) async {
    setState(() {
      isLoadingUser = true;
      userLoadError = null;
    });

    try {
      final userData = await UserService.updateUser(updatedUser);
      if (mounted) {
        setState(() {
          currentUser = userData;
          isLoadingUser = false;
          userLoadError = null;
        });
        
        _showSnackBar("Profile updated successfully!");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingUser = false;
          userLoadError = e.toString().replaceAll('Exception: ', '');
        });
        
        _showSnackBar(
          "Failed to update profile: ${e.toString().replaceAll('Exception: ', '')}", 
          isError: true
        );
      }
    }
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
        shadowColor: Color(0x1A2E7D32),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? EcoColors.primaryGreen.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? EcoColors.primaryGreen : EcoColors.textLight,
                        size: 22,
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
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              badgeCount > 99 ? '99+' : badgeCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? EcoColors.primaryGreen : EcoColors.textLight,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
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
        if (constraints.maxWidth < 400) {
          return FloatingActionButton(
            onPressed: _navigateToAddProduct,
            backgroundColor: EcoColors.secondaryGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.add_circle_outline, size: 24),
          );
        } else {
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
    
    _showSnackBar('${product.title} added to cart!');
  }

  void _removeFromCart(Product product) {
    setState(() {
      cartItems.remove(product);
    });
    
    _showSnackBar('${product.title} removed from cart', isError: true);
  }

  void _viewProductDetails(Product product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(
          product: product,
          onAddToCart: _addToCart,
          //currentUser: currentUser,
          //userId: currentUserId,
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
          //currentUserId: currentUserId,
          //currentUser: currentUser,
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
    
    _showSnackBar('New eco-friendly item added!');
  }

  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewProductScreen(
          product: product,
          onProductAdded: _updateProduct,
          //currentUserId: currentUserId,
          //currentUser: currentUser,
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
    
    _showSnackBar('Item updated successfully!');
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.eco,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: isError ? EcoColors.errorRed : EcoColors.secondaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}