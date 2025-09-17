import 'package:flutter/foundation.dart';
import 'analytics_interface.dart';
// import 'firebase_analytics_service.dart'; // Temporarily disabled - Firebase not configured
import 'mock_analytics_service.dart';

class AnalyticsServiceFactory {
  static AnalyticsServiceInterface? _instance;

  static AnalyticsServiceInterface get instance {
    _instance ??= _createAnalyticsService();
    return _instance!;
  }

  static AnalyticsServiceInterface _createAnalyticsService() {
    // Temporarily using MockAnalyticsService until Firebase is configured
    return MockAnalyticsService();

    // Original code - re-enable when Firebase is configured:
    // if (kIsWeb) {
    //   return FirebaseAnalyticsService();
    // } else if (defaultTargetPlatform == TargetPlatform.android ||
    //            defaultTargetPlatform == TargetPlatform.iOS) {
    //   return FirebaseAnalyticsService();
    // } else {
    //   return MockAnalyticsService();
    // }
  }

  static void resetInstance() {
    _instance = null;
  }

  static void setMockService() {
    _instance = MockAnalyticsService();
  }

  static void setFirebaseService() {
    // Temporarily using MockAnalyticsService until Firebase is configured
    _instance = MockAnalyticsService();
    // Original code - re-enable when Firebase is configured:
    // _instance = FirebaseAnalyticsService();
  }
}