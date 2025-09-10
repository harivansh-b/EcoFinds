import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:eco_finds/env.dart';

final String myurl = ApiConfig.baseUrl;
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

class LocationPickerScreen extends StatefulWidget {
  final Map<String, dynamic>? registrationData;
  final String userId;

  const LocationPickerScreen({
    super.key, 
    this.registrationData, 
    required this.userId
  });

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapController;
  LatLng _selectedLocation = const LatLng(13.0827, 80.2707); // Default to Chennai
  final TextEditingController _addressController = TextEditingController();
  bool isLoading = false;
  bool isCreatingUser = false;
  String? userId;
  String? username;
  String? email;
  String source = 'unknown'; // 'registration' or 'login'
  bool isExistingUser = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeData();
    _getUserLocation();
  }

  void _initializeData() {
    // First try to get data from widget parameter (registration flow)
    if (widget.registrationData != null) {
      final data = widget.registrationData!;
      source = data['source'] ?? 'registration';
      isExistingUser = data['isExistingUser'] ?? false;

      if (source == 'registration') {
        userId = data['user_id'];
        username = data['username'];
        email = data['email'];
      } else if (source == 'login') {
        userId = data['userId'];
        username = data['username'];
        email = data['email'];
      }

      print("Widget data - Source: $source, User ID: $userId, Email: $email");
    } else {
      // Fallback to widget.userId if no registrationData
      userId = widget.userId;
    }

    // Then try to get data from route arguments (login flow or fallback)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;

      if (routeArgs != null && routeArgs is Map<String, dynamic>) {
        final data = routeArgs;

        // Update values from route arguments (this takes precedence)
        source = data['source'] ?? source;
        isExistingUser = data['isExistingUser'] ?? isExistingUser;

        // Handle both naming conventions
        userId = data['userId'] ?? data['user_id'] ?? userId;
        username = data['username'] ?? username;
        email = data['email'] ?? email;

        print("Route args - Source: $source, User ID: $userId, Email: $email");

        // Trigger rebuild with new data
        if (mounted) {
          setState(() {});
        }
      }

      // Final validation
      if (userId == null || userId!.isEmpty) {
        print("ERROR: Missing User ID");
        if (mounted) {
          _showSnackBar("User ID not found. Please try again.", isError: true);
        }
      } else {
        print("SUCCESS: Data initialized - Source: $source, User ID: $userId, Email: $email");
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showSnackBar("Location services are disabled.", isError: true);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showSnackBar("Location permission denied.", isError: true);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showSnackBar(
            "Location permission permanently denied. Please enable it from app settings.",
            isError: true,
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      LatLng userLatLng = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _selectedLocation = userLatLng;
        });

        _mapController.move(userLatLng, 14.0);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error getting location: ${e.toString()}", isError: true);
      }
    }
  }

  // Create new user for registration flow
  Future<bool> createUserWithAddress() async {
    if (source != 'registration' || widget.registrationData == null) {
      _showSnackBar("Invalid operation for registration flow.", isError: true);
      return false;
    }

    final String? hashedPassword = widget.registrationData!['hashed_password'];
    final String? phone = widget.registrationData!['phone'];

    if (username == null ||
        email == null ||
        hashedPassword == null ||
        userId == null) {
      _showSnackBar("Missing essential registration data.", isError: true);
      return false;
    }

    try {
      setState(() => isCreatingUser = true);

      // Create user in database
      final response = await http.put(
        Uri.parse("$myurl/user/createuser"),
        headers: {"Content-Type": "application/json", "x-api-key": apiKey},
        body: jsonEncode({
          "_id": userId,
          "name": username,
          "pwd": hashedPassword,
          "email": email,
          "location": _addressController.text.trim(),
          "lattitude": _selectedLocation.latitude.toString(),
          "longitude": _selectedLocation.longitude.toString(),
          "createdAt": DateTime.now().toIso8601String(),
          "phoneno": phone ?? "",
          "profilePic": "",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] != null) {
          _showSnackBar(
            "Registration completed successfully! Welcome to EcoFinds!",
          );
          return true;
        } else {
          _showSnackBar(
            data['detail'] ?? data['message'] ?? "Registration failed",
            isError: true,
          );
          return false;
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(
          "Registration failed: ${errorData['detail'] ?? errorData['message'] ?? response.statusCode}",
          isError: true,
        );
        return false;
      }
    } catch (e) {
      _showSnackBar(
        "Network error during registration: ${e.toString()}",
        isError: true,
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => isCreatingUser = false);
      }
    }
  }

  // Update address for existing user (login flow)
  Future<bool> updateUserAddress() async {
    if (source != 'login' || userId == null) {
      _showSnackBar("Invalid operation for login flow.", isError: true);
      return false;
    }

    try {
      setState(() => isCreatingUser = true);

      final response = await http.patch(
        Uri.parse("$myurl/user/updateuser"),
        headers: {"Content-Type": "application/json", "x-api-key": apiKey},
        body: jsonEncode({
          "user_id": userId,
          "address": _addressController.text.trim(),
          "latitude": _selectedLocation.latitude.toString(),
          "longitude": _selectedLocation.longitude.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['message'] != null) {
          _showSnackBar("Address updated successfully!");
          return true;
        } else {
          _showSnackBar(
            data['detail'] ?? data['message'] ?? "Failed to update address",
            isError: true,
          );
          return false;
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(
          "Failed to update address: ${errorData['detail'] ?? errorData['message'] ?? response.statusCode}",
          isError: true,
        );
        return false;
      }
    } catch (e) {
      _showSnackBar(
        "Network error while updating address: ${e.toString()}",
        isError: true,
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => isCreatingUser = false);
      }
    }
  }

  Future<void> saveAddress() async {
    if (_addressController.text.trim().isEmpty) {
      _showSnackBar("Please enter your complete address", isError: true);
      return;
    }

    if (userId == null || userId!.isEmpty) {
      _showSnackBar("User ID not found. Please try again.", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      bool success = false;

      if (source == 'registration') {
        // New user registration - create user with address
        success = await createUserWithAddress();
      } else if (source == 'login') {
        // Existing user login - update address
        success = await updateUserAddress();
      } else {
        _showSnackBar(
          "Invalid navigation source. Please try again.",
          isError: true,
        );
        return;
      }

      if (success) {
        // Store user data locally if needed
        await _storeUserDataLocally();

        // Navigate to main screen
        if (!mounted) return;

        String welcomeMessage = source == 'registration'
            ? 'Welcome to EcoFinds!'
            : 'Location updated successfully!';

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (Route<dynamic> route) => false,
          arguments: {
            'userId': userId, // Changed from 'user_id' to match main.dart expectation
            'username': username,
            'email': email,
            'welcome_message': welcomeMessage,
            'source': source,
          },
        );
      }
    } catch (e) {
      _showSnackBar(
        "An unexpected error occurred: ${e.toString()}",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Store user data locally (placeholder implementation)
  Future<void> _storeUserDataLocally() async {
    // Example: Save user data to SharedPreferences
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('user_id', userId!);
    // await prefs.setString('email', email!);

    print("Storing user data locally:");
    print("User ID: $userId");
    print("Email: $email");
    print("Name: $username");
    print("Address: ${_addressController.text}");
    print(
      "Location: Lat ${_selectedLocation.latitude}, Lng ${_selectedLocation.longitude}",
    );
    print("Source: $source");
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
        action: isError
            ? SnackBarAction(
                label: 'DISMISS',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }

  String _getScreenTitle() {
    if (source == 'registration') {
      return "Complete Registration";
    } else if (source == 'login') {
      return isExistingUser
          ? "Update Delivery Location"
          : "Set Delivery Location";
    }
    return "Select Delivery Location";
  }

  String _getInstructions() {
    if (source == 'registration') {
      return "Complete your registration by selecting your delivery location";
    } else if (source == 'login') {
      return isExistingUser
          ? "Update your delivery location for better service"
          : "Set your delivery location to get started";
    }
    return "Tap on the map to select your delivery location";
  }

  String _getButtonText() {
    if (source == 'registration') {
      return "Complete Registration";
    } else if (source == 'login') {
      return isExistingUser ? "Update Location" : "Save Location";
    }
    return "Save Location";
  }

  String _getLoadingText() {
    if (isCreatingUser) {
      if (source == 'registration') {
        return "Creating Account...";
      } else {
        return "Updating Location...";
      }
    }
    return "Saving Location...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcoColors.backgroundWhite,
      appBar: AppBar(
        title: Text(
          _getScreenTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [EcoColors.primaryGreen, EcoColors.secondaryGreen],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Instructions Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EcoColors.warmBeige,
              border: Border(
                bottom: BorderSide(
                  color: EcoColors.accentGreen.withOpacity(0.3),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      source == 'registration'
                          ? Icons.person_add_outlined
                          : Icons.location_on_outlined,
                      color: EcoColors.leafGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getInstructions(),
                        style: const TextStyle(
                          color: EcoColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isCreatingUser) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: EcoColors.secondaryGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getLoadingText(),
                        style: const TextStyle(
                          color: EcoColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Map Section
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 10.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                      _mapController.move(point, _mapController.camera.zoom);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.ecofinds',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 80.0,
                          height: 80.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: EcoColors.primaryGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: EcoColors.primaryGreen.withOpacity(
                                    0.4,
                                  ),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Current Location Button
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: EcoColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: EcoColors.primaryGreen.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        color: EcoColors.secondaryGreen,
                      ),
                      onPressed: _getUserLocation,
                      tooltip: "Get Current Location",
                    ),
                  ),
                ),

                // Zoom Control Buttons
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              EcoColors.primaryGreen,
                              EcoColors.secondaryGreen,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: EcoColors.primaryGreen.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              EcoColors.primaryGreen,
                              EcoColors.secondaryGreen,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: EcoColors.primaryGreen.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Address Input Panel
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: EcoColors.cardBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: EcoColors.primaryGreen.withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: EcoColors.textLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section Header
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: EcoColors.secondaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Confirm Your Address",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: EcoColors.textDark,
                      ),
                    ),
                  ],
                ),

                // Show user info if available
                if (email != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    source == 'registration'
                        ? "Creating account for: $email"
                        : "Updating location for: $email",
                    style: const TextStyle(
                      fontSize: 12,
                      color: EcoColors.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else if (userId == null || userId!.isEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EcoColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: EcoColors.errorRed.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: EcoColors.errorRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "No user data found. Please go back and try again.",
                            style: TextStyle(
                              fontSize: 12,
                              color: EcoColors.errorRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Address Input Field
                Container(
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
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Enter your complete address with landmarks...",
                      hintStyle: const TextStyle(color: EcoColors.textLight),
                      prefixIcon: const Icon(
                        Icons.home_outlined,
                        color: EcoColors.secondaryGreen,
                      ),
                      filled: true,
                      fillColor: EcoColors.backgroundWhite,
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
                    ),
                    style: const TextStyle(color: EcoColors.textDark),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: (userId != null && userId!.isNotEmpty)
                        ? const LinearGradient(
                            colors: [
                              EcoColors.primaryGreen,
                              EcoColors.secondaryGreen,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    color: (userId == null || userId!.isEmpty)
                        ? EcoColors.textLight
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: (userId != null && userId!.isNotEmpty)
                        ? [
                            BoxShadow(
                              color: EcoColors.primaryGreen.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed:
                        (isLoading ||
                            isCreatingUser ||
                            userId == null ||
                            userId!.isEmpty)
                        ? null
                        : saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: (isLoading || isCreatingUser)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _getLoadingText(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getButtonText(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (userId != null && userId!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  source == 'registration'
                                      ? Icons.check_circle_outline
                                      : Icons.location_on_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}