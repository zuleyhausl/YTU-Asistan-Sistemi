import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// App-wide constants and environment configuration.
///
/// The backend (Express, see ../../../BACKEND_API.md) listens on port 3000 by
/// default. Android emulators reach the host machine via 10.0.2.2; iOS
/// simulators and desktop reach it via localhost.
class AppConstants {
  AppConstants._();

  static const String appName = 'YTU Assistant';
  static const String appFullName = 'YTU Assistant Recruitment System';

  /// Backend port (`process.env.PORT || 3000` in backend/app.js).
  static const int backendPort = 3000;

  /// Resolved base URL for the current platform.
  ///
  /// - Android emulator: http://10.0.2.2:3000
  /// - iOS simulator / macOS / others: http://localhost:3000
  ///
  /// On a real device, override this with the host machine's LAN IP.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$backendPort';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$backendPort';
    }
    return 'http://localhost:$backendPort';
  }

  /// Network timeouts.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Secure storage keys.
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  /// University email domains used by the backend to assign roles.
  static const String studentEmailDomain = '@std.yildiz.edu.tr';
  static const String professorEmailDomain = '@yildiz.edu.tr';
}
