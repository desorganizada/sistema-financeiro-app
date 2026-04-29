import 'package:flutter/foundation.dart';

class AppConstants {
  static const String productionBaseUrl = 'https://sistema-financeiro-app.onrender.com';
  static const String localBaseUrl = 'http://localhost:8000';   // para web ou emulador iOS
  // static const String localBaseUrl = 'http://10.0.2.2:8000'; // para emulador Android

  static String get baseUrl => kDebugMode ? localBaseUrl : productionBaseUrl;
}