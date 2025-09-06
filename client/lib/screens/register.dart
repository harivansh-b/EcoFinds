import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'location_picker.dart';

const String myurl = "http://127.0.0.1:8000";
const String apiKey = "auth_api@12!_23";

// EcoFinds Color Palette
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
}

class CompleteRegisterScreen extends StatefulWidget {
  const CompleteRegisterScreen({super.key});

  @override
  State<CompleteRegisterScreen> createState() => _CompleteRegisterScreenState();
}

class _CompleteRegisterScreenState extends State<CompleteRegisterScreen> {
  // Controllers for all input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isObscurePassword = true;
  bool isObscureConfirm = true;
  bool isLoading = false;
  bool acceptTerms = false;
  bool showOtpField = false;
  bool isOtpSent = false;
  bool isVerifyingOtp = false;

  Timer? _timer;
  int _resendCountdown = 0;

  // Store signup data and user ID
  Map<String, dynamic>? signupData;
  String? generatedUserId;

  @override
  void dispose() {
    _timer?.cancel();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  // Step 1: Check signup eligibility
  Future<bool> checkSignupEligibility() async {
    try {
      final response = await http.post(
        Uri.parse("$myurl/auth/email/signup"),
        headers: {"Content-Type": "application/json", "x-api-key": apiKey},
        body: jsonEncode({
          "username": nameController.text.trim(),
          "email": emailController.text.trim(),
          "pwd": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        signupData = data['session_details'];
        return true;
      } else {
        _showSnackBar(data['message'] ?? "User already exists", isError: true);
        return false;
      }
    } catch (e) {
      _showSnackBar("Network error. Please try again.", isError: true);
      return false;
    }
  }

  // Step 2: Send OTP
  Future<bool> sendOtp() async {
    try {
      final response = await http.post(
        Uri.parse("$myurl/auth/email/signup/sendotp"),
        headers: {"Content-Type": "application/json", "x-api-key": apiKey},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showSnackBar(data['message'] ?? "OTP sent successfully!");
        _startResendCountdown();
        return true;
      } else {
        _showSnackBar("Failed to send OTP. Please try again.", isError: true);
        return false;
      }
    } catch (e) {
      _showSnackBar("Network error. Please try again.", isError: true);
      return false;
    }
  }

  // Step 3: Verify OTP and get user ID
  Future<bool> verifyOtp() async {
    try {
      final response = await http.post(
        Uri.parse("$myurl/auth/email/verifyotp"),
        headers: {"Content-Type": "application/json", "x-api-key": apiKey},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "otp": otpController.text.trim(),
          "username": nameController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // Store the generated user ID
        generatedUserId = data['userid'];
        return true;
      } else {
        _showSnackBar(data['detail'] ?? "Invalid OTP", isError: true);
        return false;
      }
    } catch (e) {
      _showSnackBar(
        "OTP verification failed. Please try again.",
        isError: true,
      );
      return false;
    }
  }

  // Complete registration process
  Future<void> registerUser() async {
    if (!_validateInputs()) return;

    setState(() => isLoading = true);

    try {
      // Step 1: Check signup eligibility
      bool canSignup = await checkSignupEligibility();
      if (!canSignup) {
        setState(() => isLoading = false);
        return;
      }

      // Step 2: Send OTP
      bool otpSent = await sendOtp();
      if (otpSent) {
        setState(() {
          showOtpField = true;
          isOtpSent = true;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Registration failed. Please try again.", isError: true);
    }
  }

  // Verify OTP and navigate to location screen
  Future<void> verifyAndCompleteRegistration() async {
    if (otpController.text.trim().isEmpty) {
      _showSnackBar("Please enter the OTP", isError: true);
      return;
    }

    setState(() => isVerifyingOtp = true);

    try {
      // Step 3: Verify OTP
      bool isOtpValid = await verifyOtp();

      if (!isOtpValid) {
        setState(() => isVerifyingOtp = false);
        return;
      }

      _showSnackBar("OTP verified successfully!");

      // Navigate to LocationPickerScreen with the correct data structure
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerScreen(
            registrationData: {
              'user_id': generatedUserId,
              'username': nameController.text.trim(),
              'email': emailController.text.trim(),
              'hashed_password': signupData!['hashed_password'],
              'phone': phoneController.text.trim(),
            },
          ),
        ),
      );
    } catch (e) {
      _showSnackBar("Registration failed. Please try again.", isError: true);
    } finally {
      setState(() => isVerifyingOtp = false);
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() => isLoading = true);

    bool otpSent = await sendOtp();
    if (otpSent) {
      otpController.clear();
      _showSnackBar("New OTP sent successfully!");
    }

    setState(() => isLoading = false);
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnackBar("Please fill in all fields", isError: true);
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match", isError: true);
      return false;
    }

    if (passwordController.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters", isError: true);
      return false;
    }

    if (!acceptTerms) {
      _showSnackBar("Please accept the terms and conditions", isError: true);
      return false;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text)) {
      _showSnackBar("Please enter a valid email address", isError: true);
      return false;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phoneController.text.trim())) {
      _showSnackBar(
        "Please enter a valid 10-digit phone number",
        isError: true,
      );
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? EcoColors.errorRed
            : EcoColors.secondaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    bool isOtp = false,
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
      child: TextField(
        controller: controller,
        obscureText: isPassword
            ? isObscurePassword
            : (isConfirmPassword ? isObscureConfirm : false),
        keyboardType: keyboardType,
        maxLength: isOtp ? 6 : null,
        textAlign: isOtp ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: isOtp ? 18 : 16,
          fontWeight: isOtp ? FontWeight.bold : FontWeight.normal,
          letterSpacing: isOtp ? 8 : 0,
        ),
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
          counterText: "",
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
                      ),
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

                // Logo
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

                // Title
                Text(
                  showOtpField ? "Verify Your Email" : "Create Account",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: EcoColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showOtpField
                      ? "Enter the 6-digit code sent to ${emailController.text}"
                      : "Start your sustainable journey today",
                  style: TextStyle(fontSize: 16, color: EcoColors.textLight),
                ),
                const SizedBox(height: 30),

                if (showOtpField) ...[
                  _buildTextField(
                    controller: otpController,
                    hintText: "Enter OTP",
                    prefixIcon: Icons.security,
                    keyboardType: TextInputType.number,
                    isOtp: true,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(color: EcoColors.textLight),
                      ),
                      TextButton(
                        onPressed: _resendCountdown > 0 ? null : resendOtp,
                        child: Text(
                          _resendCountdown > 0
                              ? "Resend in ${_resendCountdown}s"
                              : "Resend OTP",
                          style: TextStyle(
                            color: _resendCountdown > 0
                                ? EcoColors.textLight
                                : EcoColors.secondaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  _buildTextField(
                    controller: nameController,
                    hintText: "Full Name",
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: emailController,
                    hintText: "Email Address",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: phoneController,
                    hintText: "Phone Number",
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: passwordController,
                    hintText: "Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    prefixIcon: Icons.lock_outline,
                    isConfirmPassword: true,
                  ),
                  const SizedBox(height: 20),

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
                ],

                // Action Button
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
                    onPressed: (isLoading || isVerifyingOtp)
                        ? null
                        : showOtpField
                        ? verifyAndCompleteRegistration
                        : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: (isLoading || isVerifyingOtp)
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                showOtpField
                                    ? "Verify & Continue"
                                    : "Create Account",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                showOtpField
                                    ? Icons.check_circle
                                    : Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),

                if (!showOtpField) ...[
                  const SizedBox(height: 30),

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
                ],

                const SizedBox(height: 30),

                if (!showOtpField)
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
