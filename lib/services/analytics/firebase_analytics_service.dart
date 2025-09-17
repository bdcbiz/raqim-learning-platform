// TEMPORARILY DISABLED: Firebase Analytics is not configured
// This file will be re-enabled once Firebase dependencies are properly installed

import 'package:flutter/foundation.dart';
import 'analytics_interface.dart';

/// Firebase Analytics implementation - currently disabled
/// Using MockAnalyticsService instead until Firebase is configured
class FirebaseAnalyticsService implements AnalyticsServiceInterface {

  @override
  Future<void> initialize() async {
    if (kDebugMode) {
      print('FirebaseAnalyticsService: Disabled - Firebase not configured');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (kDebugMode) {
      print('FirebaseAnalyticsService: setUserId disabled - Firebase not configured');
    }
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    if (kDebugMode) {
      print('FirebaseAnalyticsService: setUserProperty disabled - Firebase not configured');
    }
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    if (kDebugMode) {
      print('FirebaseAnalyticsService: setCurrentScreen disabled - Firebase not configured');
    }
  }

  @override
  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    if (kDebugMode) {
      print('FirebaseAnalyticsService: logEvent disabled - Firebase not configured');
    }
  }

  @override
  Future<void> logLogin(String loginMethod) async {
    await logEvent('login', {'login_method': loginMethod});
  }

  @override
  Future<void> logSignUp(String signUpMethod) async {
    await logEvent('sign_up', {'sign_up_method': signUpMethod});
  }

  @override
  Future<void> logSearch(String searchTerm) async {
    await logEvent('search', {'search_term': searchTerm});
  }

  @override
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
    String? itemName,
  }) async {
    await logEvent('select_content', {
      'content_type': contentType,
      'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
    });
  }

  @override
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    await logEvent('share', {
      'content_type': contentType,
      'item_id': itemId,
      if (method != null) 'method': method,
    });
  }

  @override
  Future<void> logCourseView(String courseId, String courseName) async {
    await logEvent('course_view', {
      'course_id': courseId,
      'course_name': courseName,
    });
  }

  @override
  Future<void> logCourseEnroll(String courseId, String courseName) async {
    await logEvent('course_enroll', {
      'course_id': courseId,
      'course_name': courseName,
    });
  }

  @override
  Future<void> logLessonStart(String courseId, String lessonId) async {
    await logEvent('lesson_start', {
      'course_id': courseId,
      'lesson_id': lessonId,
    });
  }

  @override
  Future<void> logLessonComplete(String courseId, String lessonId) async {
    await logEvent('lesson_complete', {
      'course_id': courseId,
      'lesson_id': lessonId,
    });
  }

  @override
  Future<void> logCourseComplete(String courseId, String courseName) async {
    await logEvent('course_complete', {
      'course_id': courseId,
      'course_name': courseName,
    });
  }

  @override
  Future<void> logPurchase({
    required String currency,
    required double value,
    required String transactionId,
    String? affiliation,
    String? coupon,
    String? shipping,
    String? tax,
    List<Map<String, Object>>? items,
  }) async {
    await logEvent('purchase', {
      'currency': currency,
      'value': value,
      'transaction_id': transactionId,
      if (affiliation != null) 'affiliation': affiliation,
      if (coupon != null) 'coupon': coupon,
      if (shipping != null) 'shipping': shipping,
      if (tax != null) 'tax': tax,
      if (items != null) 'items': items,
    });
  }

  @override
  Future<void> logVideoPlay(String videoId, String videoTitle) async {
    await logEvent('video_play', {
      'video_id': videoId,
      'video_title': videoTitle,
    });
  }

  @override
  Future<void> logVideoPause(String videoId, int watchTime) async {
    await logEvent('video_pause', {
      'video_id': videoId,
      'watch_time_seconds': watchTime,
    });
  }

  @override
  Future<void> logVideoComplete(String videoId, int totalTime) async {
    await logEvent('video_complete', {
      'video_id': videoId,
      'total_time_seconds': totalTime,
    });
  }

  @override
  Future<void> logQuizStart(String quizId) async {
    await logEvent('quiz_start', {
      'quiz_id': quizId,
    });
  }

  @override
  Future<void> logQuizComplete(String quizId, int score, int totalQuestions) async {
    await logEvent('quiz_complete', {
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'percentage': ((score / totalQuestions) * 100).round(),
    });
  }

  @override
  Future<void> logPostCreate(String postId, String category) async {
    await logEvent('post_create', {
      'post_id': postId,
      'category': category,
    });
  }

  @override
  Future<void> logPostView(String postId) async {
    await logEvent('post_view', {
      'post_id': postId,
    });
  }

  @override
  Future<void> logPostLike(String postId) async {
    await logEvent('post_like', {
      'post_id': postId,
    });
  }

  @override
  Future<void> logPostShare(String postId) async {
    await logEvent('post_share', {
      'post_id': postId,
    });
  }

  @override
  Future<void> logError(String errorMessage, {
    String? stackTrace,
    bool? fatal,
  }) async {
    await logEvent('app_error', {
      'error_message': errorMessage,
      if (stackTrace != null) 'stack_trace': stackTrace,
      'fatal': fatal ?? false,
    });
  }

  @override
  Future<void> logLearningProgress({
    required String courseId,
    required int completedLessons,
    required int totalLessons,
    required double progressPercentage,
  }) async {
    await logEvent('learning_progress', {
      'course_id': courseId,
      'completed_lessons': completedLessons,
      'total_lessons': totalLessons,
      'progress_percentage': progressPercentage,
    });
  }

  @override
  Future<void> logCertificateEarned(String certificateId, String courseId) async {
    await logEvent('certificate_earned', {
      'certificate_id': certificateId,
      'course_id': courseId,
    });
  }

  @override
  Future<void> logPageLoadTime(String pageName, int loadTimeMs) async {
    await logEvent('page_load_time', {
      'page_name': pageName,
      'load_time_ms': loadTimeMs,
    });
  }

  @override
  Future<void> logAppLaunch(String launchMode) async {
    await logEvent('app_launch', {
      'launch_mode': launchMode,
    });
  }

  @override
  Future<void> logAppBackground() async {
    await logEvent('app_background', {});
  }

  @override
  Future<void> logAppForeground() async {
    await logEvent('app_foreground', {});
  }
}

/* ORIGINAL CODE - TO BE RESTORED WHEN FIREBASE IS CONFIGURED:

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'analytics_interface.dart';

class FirebaseAnalyticsService implements AnalyticsServiceInterface {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  static FirebaseAnalytics get analytics {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  static FirebaseAnalyticsObserver get observer {
    _observer ??= FirebaseAnalyticsObserver(analytics: analytics);
    return _observer!;
  }

  // ... rest of the original implementation
}

*/