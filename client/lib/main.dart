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
          return LocationPickerScreen(
            userId: args?['userId'] ?? '',
          );
        },
        // Updated route to match LocationPickerScreen navigation
        '/home': (context) {
          // Get user data arguments from LocationPickerScreen
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final String userId = args?['userId'] ?? '';
          
          // Ensure userId is not empty
          if (userId.isEmpty) {
            // If no userId is provided, redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });
            // Return a loading screen while redirecting
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Redirecting to login...'),
                  ],
                ),
              ),
            );
          }
          
          return MainScreen(
            userId: userId,
          );
        },
        // Keep the '/main' route as well for backward compatibility
        '/main': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final String userId = args?['userId'] ?? '';
          
          // Ensure userId is not empty
          if (userId.isEmpty) {
            // If no userId is provided, redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });
            // Return a loading screen while redirecting
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Redirecting to login...'),
                  ],
                ),
              ),
            );
          }
          
          return MainScreen(
            userId: userId,
          );
        },
      },
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },
      // Global route error handling
      onGenerateRoute: (settings) {
        // Handle dynamic routes if needed
        switch (settings.name) {
          case '/home':
          case '/main':
            final args = settings.arguments as Map<String, dynamic>?;
            final String userId = args?['userId'] ?? '';
            
            if (userId.isEmpty) {
              // Redirect to login if no userId
              return MaterialPageRoute(
                builder: (context) => const CleanLoginScreen(),
              );
            }
            
            return MaterialPageRoute(
              builder: (context) => MainScreen(userId: userId),
              settings: settings,
            );
          default:
            return null; // Let the regular routes handle it
        }
      },
    );
  }
}