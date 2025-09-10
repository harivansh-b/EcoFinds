import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register.dart';

import 'package:eco_finds/env.dart';

final String myurl = ApiConfig.baseUrl;
const String apiKey = "auth_api@12!_23";

// EcoFinds Color Palette
class EcoColors {
  static const Color primaryGreen = Color(0xFF2E7D32); // Deep forest green
  static const Color secondaryGreen = Color(0xFF4CAF50); // Fresh green
  static const Color accentGreen = Color(0xFF81C784); // Light green
  static const Color earthBrown = Color(0xFF5D4037); // Earth brown
  static const Color warmBeige = Color(0xFFF1F8E9); // Warm beige
  static const Color leafGreen = Color(0xFF66BB6A); // Leaf green
  static const Color skyBlue = Color(0xFF03DAC6); // Eco teal
  static const Color backgroundWhite = Color(0xFFFAFAFA); // Soft white
  static const Color textDark = Color(0xFF1B5E20); // Dark green text
  static const Color textLight = Color(0xFF757575); // Light grey text
  static const Color cardBackground = Colors.white;
  static const Color errorRed = Color(0xFFE53935);
}

// API Service Class
class AuthService {
  static final String baseUrl = myurl;
  static const String authApiKey = apiKey;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/email/login"),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": authApiKey,
        },
        body: jsonEncode({
          "email": email,
          "pwd": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception("Unauthorized access - Invalid API key");
      } else if (response.statusCode == 500) {
        throw Exception("Server error - Please try again later");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? "Login failed");
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Network error - Please check your internet connection");
    }
  }

  // Check if user has address saved
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/profile/$userId"),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": authApiKey,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch user profile");
      }
    } catch (e) {
      throw Exception("Error fetching user profile: ${e.toString()}");
    }
  }
}

class CleanLoginScreen extends StatefulWidget {
  const CleanLoginScreen({super.key});

  @override
  State<CleanLoginScreen> createState() => _CleanLoginScreenState();
}

class _CleanLoginScreenState extends State<CleanLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isObscure = true;
  bool isLoading = false;

  // Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validator
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Updated login function with address check
  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final sessionDetails = result['session_details'];
        final userId = sessionDetails['id'];
        final username = sessionDetails['username'];
        final email = sessionDetails['email'];

        // Check if user has address/location saved
        try {
          final userProfile = await AuthService.getUserProfile(userId);
          
          bool hasAddress = false;
          bool hasLocation = false;

          if (userProfile['user'] != null) {
            final user = userProfile['user'];
            hasAddress = user['location'] != null && user['location'].toString().trim().isNotEmpty;
            hasLocation = (user['lattitude'] != null && user['longitude'] != null) &&
                         (user['lattitude'].toString().trim().isNotEmpty && user['longitude'].toString().trim().isNotEmpty);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Welcome back, $username!"),
              backgroundColor: EcoColors.secondaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate based on user's profile completeness
          if (hasAddress && hasLocation) {
            // User has complete profile, go to main screen
            Navigator.pushReplacementNamed(
              context,
              '/main',
              arguments: {
                'userId': userId,
                'username': username,
                'email': email,
                'source': 'login',
              },
            );
          } else {
            // User needs to set up location, go to location picker
            Navigator.pushReplacementNamed(
              context,
              '/location',
              arguments: {
                'userId': userId,
                'username': username,
                'email': email,
                'source': 'login',
                'isExistingUser': true,
              },
            );
          }
        } catch (profileError) {
          // If profile check fails, still proceed to location picker for safety
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Welcome back, $username!"),
              backgroundColor: EcoColors.secondaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pushReplacementNamed(
            context,
            '/location',
            arguments: {
              'userId': userId,
              'username': username,
              'email': email,
              'source': 'login',
              'isExistingUser': true,
            },
          );
        }
      } else {
        // Handle login failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Login failed"),
            backgroundColor: EcoColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: EcoColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Reusable text field with EcoFinds styling and validation
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isPassword ? isObscure : false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: EcoColors.textLight),
          prefixIcon: Icon(prefixIcon, color: EcoColors.secondaryGreen),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: EcoColors.secondaryGreen,
                  ),
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: EcoColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: EcoColors.accentGreen.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: EcoColors.accentGreen.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: EcoColors.secondaryGreen,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: EcoColors.errorRed,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: EcoColors.errorRed,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // Reusable social login button with eco styling
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: EcoColors.cardBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 28),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcoColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo with eco-friendly styling
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: EcoColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: EcoColors.primaryGreen,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "EcoFinds",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: EcoColors.primaryGreen,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Discover Sustainable Living",
                    style: TextStyle(
                      fontSize: 16,
                      color: EcoColors.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Login Title
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: EcoColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to continue your eco journey",
                    style: TextStyle(fontSize: 16, color: EcoColors.textLight),
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  _buildTextField(
                    controller: emailController,
                    hintText: "Email address",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildTextField(
                    controller: passwordController,
                    hintText: "Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forgot password screen
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text(
                        "Forgot Your Password?",
                        style: TextStyle(
                          color: EcoColors.secondaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button with gradient effect
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          EcoColors.primaryGreen,
                          EcoColors.secondaryGreen,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: EcoColors.primaryGreen.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Social Login Section
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: EcoColors.textLight.withOpacity(0.3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Or Login with",
                          style: TextStyle(color: EcoColors.textLight),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: EcoColors.textLight.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        color: const Color(0xFF1877F2),
                        onPressed: () {
                          // TODO: Implement Facebook login
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Facebook login coming soon!"),
                              backgroundColor: EcoColors.secondaryGreen,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: Icons.apple,
                        color: Colors.black,
                        onPressed: () {
                          // TODO: Implement Apple login
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Apple login coming soon!"),
                              backgroundColor: EcoColors.secondaryGreen,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        color: const Color(0xFFDB4437),
                        onPressed: () {
                          // TODO: Implement Google login
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Google login coming soon!"),
                              backgroundColor: EcoColors.secondaryGreen,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: EcoColors.textLight),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: EcoColors.secondaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}