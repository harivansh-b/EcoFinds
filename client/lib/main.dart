import 'package:flutter/material.dart';
import 'screens/location_picker.dart';
import 'screens/login.dart';
import 'screens/main_screen.dart';
import 'screens/register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoFinds App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const CleanLoginScreen(),
        '/register': (context) => const CompleteRegisterScreen(),
        '/location': (context) {
          // Get user data from arguments passed from login/registration
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return const LocationPickerScreen();
        },
        // Updated route to match LocationPickerScreen navigation
        '/home': (context) {
          // Get user data arguments from LocationPickerScreen
          return const MainScreen();
        },
        // Keep the '/main' route as well for backward compatibility
        '/main': (context) {
          return const MainScreen();
        },
      },
    );
  }
}