import 'package:flutter/foundation.dart';
import 'analytics_interface.dart';
import 'firebase_analytics_service.dart';
import 'mock_analytics_service.dart';

class AnalyticsServiceFactory {
  static AnalyticsServiceInterface? _instance;

  static AnalyticsServiceInterface get instance {
    _instance ??= _createAnalyticsService();
    return _instance!;
  }

  static AnalyticsServiceInterface _createAnalyticsService() {
    if (kIsWeb) {
      return FirebaseAnalyticsService();
    } else if (defaultTargetPlatform == TargetPlatform.android ||
               defaultTargetPlatform == TargetPlatform.iOS) {
      return FirebaseAnalyticsService();
    } else {
      return MockAnalyticsService();
    }
  }

  static void resetInstance() {
    _instance = null;
  }

  static void setMockService() {
    _instance = MockAnalyticsService();
  }

  static void setFirebaseService() {
    _instance = FirebaseAnalyticsService();
  }
}