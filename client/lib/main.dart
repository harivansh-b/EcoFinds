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
        '/login': (context) => CleanLoginScreen(),
        '/register': (context) => CleanRegisterScreen(),
        '/location': (context) {
          // Get userId from arguments if passed
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return LocationPickerScreen(
            userId: args ?? 'USER123',
          );
        },
        '/main': (context) {
          // Simply return MainScreen without any parameters
          // The MainScreen will handle its own state internally
          return const MainScreen();
        },
      },
    );
  }
}