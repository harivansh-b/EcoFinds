import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String myurl = "http://your-api-url.com";

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

class CleanRegisterScreen extends StatefulWidget {
  const CleanRegisterScreen({super.key});

  @override
  State<CleanRegisterScreen> createState() => _CleanRegisterScreenState();
}

class _CleanRegisterScreenState extends State<CleanRegisterScreen> {
  // Controllers for all input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isObscurePassword = true;
  bool isObscureConfirm = true;
  bool isLoading = false;
  bool acceptTerms = false;

  // Registration function with proper navigation
  Future<void> registerUser() async {
    // Validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill in all fields"),
          backgroundColor: EcoColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Passwords do not match"),
          backgroundColor: EcoColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Password must be at least 6 characters"),
          backgroundColor: EcoColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please accept the terms and conditions"),
          backgroundColor: EcoColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // For demo purposes - replace with actual API call
      // final response = await http.post(
      //   Uri.parse("$myurl/register"),
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({
      //     "name": nameController.text.trim(),
      //     "email": emailController.text.trim(),
      //     "phone": phoneController.text.trim(),
      //     "password": passwordController.text,
      //   }),
      // );

      // Simulate successful registration for demo
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      if (!mounted) return;

      // Simulate successful response
      bool registerSuccess = true; // Replace with actual response check

      if (registerSuccess) {
        String userId = "USER_${DateTime.now().millisecondsSinceEpoch}"; // Generate demo user ID

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Registration successful! Welcome to EcoFinds!"),
            backgroundColor: EcoColors.secondaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to location picker using named route
        Navigator.pushReplacementNamed(
          context,
          '/location',
          arguments: userId,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Registration failed"),
            backgroundColor: EcoColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Network error. Please try again."),
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

  // Updated reusable text field with EcoFinds styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isConfirmPassword = false,
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
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscurePassword : (isConfirmPassword ? isObscureConfirm : false),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: EcoColors.textLight),
          prefixIcon: Icon(prefixIcon, color: EcoColors.secondaryGreen),
          suffixIcon: isPassword || isConfirmPassword
              ? IconButton(
                  icon: Icon(
                    (isPassword ? isObscurePassword : isObscureConfirm)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: EcoColors.secondaryGreen,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        isObscurePassword = !isObscurePassword;
                      } else if (isConfirmPassword) {
                        isObscureConfirm = !isObscureConfirm;
                      }
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: EcoColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: EcoColors.accentGreen.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: EcoColors.accentGreen.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: EcoColors.secondaryGreen, width: 2),
          ),
        ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: EcoColors.cardBackground,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: EcoColors.primaryGreen.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: EcoColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

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
                  "Join the Green Revolution",
                  style: TextStyle(
                    fontSize: 16,
                    color: EcoColors.textLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 40),

                // Register Title
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: EcoColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Start your sustainable journey today",
                  style: TextStyle(
                    fontSize: 16,
                    color: EcoColors.textLight,
                  ),
                ),
                const SizedBox(height: 30),

                // Name Field
                _buildTextField(
                  controller: nameController,
                  hintText: "Full Name",
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Email Field
                _buildTextField(
                  controller: emailController,
                  hintText: "Email Address",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Phone Field
                _buildTextField(
                  controller: phoneController,
                  hintText: "Phone Number",
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Password Field
                _buildTextField(
                  controller: passwordController,
                  hintText: "Password",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                _buildTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  prefixIcon: Icons.lock_outline,
                  isConfirmPassword: true,
                ),
                const SizedBox(height: 20),

                // Terms and Conditions Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          acceptTerms = value ?? false;
                        });
                      },
                      activeColor: EcoColors.secondaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            acceptTerms = !acceptTerms;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: EcoColors.textLight,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: "I agree to the "),
                                TextSpan(
                                  text: "Terms of Service",
                                  style: TextStyle(
                                    color: EcoColors.secondaryGreen,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: " and "),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: TextStyle(
                                    color: EcoColors.secondaryGreen,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Register Button with gradient
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [EcoColors.primaryGreen, EcoColors.secondaryGreen],
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
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
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
                                "Create Account",
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
                const SizedBox(height: 30),

                // Divider with eco benefits
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: EcoColors.warmBeige,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: EcoColors.accentGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.eco,
                            color: EcoColors.leafGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Join our eco-community and get:",
                            style: TextStyle(
                              color: EcoColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(width: 28),
                          Expanded(
                            child: Text(
                              "• Exclusive access to sustainable products\n• Eco-tips and green living guides\n• Community rewards and discounts",
                              style: TextStyle(
                                color: EcoColors.textLight,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: EcoColors.textLight),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Sign In",
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
    );
  }
}