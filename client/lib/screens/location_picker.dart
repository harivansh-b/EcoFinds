import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

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

class LocationPickerScreen extends StatefulWidget {
  final String userId;

  const LocationPickerScreen({
    super.key,
    required this.userId,
  });

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapController;
  LatLng _selectedLocation = LatLng(13.0827, 80.2707); // Default to Chennai
  final TextEditingController _addressController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Location services are disabled."),
          backgroundColor: EcoColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Location permission denied."),
            backgroundColor: EcoColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Location permission permanently denied."),
          backgroundColor: EcoColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng userLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _selectedLocation = userLatLng;
    });

    _mapController.move(userLatLng, 14.0);
  }

  Future<void> saveAddress() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter your address"),
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
      //   Uri.parse("$myurl/add_address"),
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({
      //     "User_ID": widget.userId,
      //     "address": _addressController.text,
      //     "latitude": _selectedLocation.latitude,
      //     "longitude": _selectedLocation.longitude,
      //   }),
      // );

      // Simulate successful save for demo
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      if (!mounted) return;

      // Simulate successful response
      bool saveSuccess = true; // Replace with actual response check

      if (saveSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Address saved successfully!"),
            backgroundColor: EcoColors.secondaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to main screen using named route with arguments
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Error saving address"),
            backgroundColor: EcoColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("An error occurred. Please try again."),
          backgroundColor: EcoColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcoColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          "Select Delivery Location",
          style: TextStyle(
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
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: EcoColors.leafGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Tap on the map to select your delivery location",
                    style: TextStyle(
                      color: EcoColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
                      _mapController.move(point, _mapController.zoom);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
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
                                  color: EcoColors.primaryGreen.withOpacity(0.4),
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
                      icon: Icon(
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
                          gradient: LinearGradient(
                            colors: [EcoColors.primaryGreen, EcoColors.secondaryGreen],
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
                              _mapController.center,
                              _mapController.zoom + 1,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [EcoColors.primaryGreen, EcoColors.secondaryGreen],
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
                              _mapController.center,
                              _mapController.zoom - 1,
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
                    Icon(
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
                      hintStyle: TextStyle(color: EcoColors.textLight),
                      prefixIcon: Icon(
                        Icons.home_outlined,
                        color: EcoColors.secondaryGreen,
                      ),
                      filled: true,
                      fillColor: EcoColors.backgroundWhite,
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
                    style: TextStyle(color: EcoColors.textDark),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Confirm Button
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
                    onPressed: isLoading ? null : saveAddress,
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
                                "Confirm & Save Location",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
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