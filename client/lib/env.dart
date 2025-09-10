import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Web apps can reach localhost directly
      return "http://127.0.0.1:8000";
    } else if (Platform.isAndroid) {
      // Emulator vs real device check
      // For emulator → 10.0.2.2
      // For real device → use your PC’s LAN IP
      const bool isEmulator = false; // 🔥 Change this when testing on emulator
      return isEmulator
          ? "http://10.0.2.2:8000"
          : "http://192.168.1.6:8000"; // <-- your PC's Wi-Fi IP
    } else if (Platform.isIOS) {
      // iOS simulator → localhost
      // Real device → use PC’s LAN IP
      const bool isSimulator = true; // 🔥 Change this when testing on simulator
      return isSimulator
          ? "http://127.0.0.1:8000"
          : "http://192.168.1.6:8000";
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop apps can use localhost
      return "http://127.0.0.1:8000";
    } else {
      // Fallback
      return "http://192.168.1.6:8000";
    }
  }
}
