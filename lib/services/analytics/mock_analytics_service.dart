import 'package:flutter/foundation.dart';
import 'analytics_interface.dart';

class MockAnalyticsService implements AnalyticsServiceInterface {
  @override
  Future<void> initialize() async {
    if (kDebugMode) {
      print('Mock Analytics Service initialized');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    _logMockEvent('setUserId', {'userId': userId});
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    _logMockEvent('setUserProperty', {'name': name, 'value': value});
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    _logMockEvent('setCurrentScreen', {
      'screenName': screenName,
      'screenClass': screenClass,
    });
  }

  @override
  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    _logMockEvent(name, parameters);
  }

  @override
  Future<void> logLogin(String loginMethod) async {
    _logMockEvent('login', {'login_method': loginMethod});
  }

  @override
  Future<void> logSignUp(String signUpMethod) async {
    _logMockEvent('sign_up', {'sign_up_method': signUpMethod});
  }

  @override
  Future<void> logSearch(String searchTerm) async {
    _logMockEvent('search', {'search_term': searchTerm});
  }

  @override
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
    String? itemName,
  }) async {
    _logMockEvent('select_content', {
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
    _logMockEvent('share', {
      'content_type': contentType,
      'item_id': itemId,
      if (method != null) 'method': method,
    });
  }

  @override
  Future<void> logCourseView(String courseId, String courseName) async {
    _logMockEvent('course_view', {
      'course_id': courseId,
      'course_name': courseName,
    });
  }

  @override
  Future<void> logCourseEnroll(String courseId, String courseName) async {
    _logMockEvent('course_enroll', {
      'course_id': courseId,
      'course_name': courseName,
    });
  }

  @override
  Future<void> logLessonStart(String courseId, String lessonId) async {
    _logMockEvent('lesson_start', {
      'course_id': courseId,
      'lesson_id': lessonId,
    });
  }

  @override
  Future<void> logLessonComplete(String courseId, String lessonId) async {
    _logMockEvent('lesson_complete', {
      'course_id': courseId,
      'lesson_id': lessonId,
    });
  }

  @override
  Future<void> logCourseComplete(String courseId, String courseName) async {
    _logMockEvent('course_complete', {
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
    _logMockEvent('purchase', {
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
    _logMockEvent('video_play', {
      'video_id': videoId,
      'video_title': videoTitle,
    });
  }

  @override
  Future<void> logVideoPause(String videoId, int watchTime) async {
    _logMockEvent('video_pause', {
      'video_id': videoId,
      'watch_time_seconds': watchTime,
    });
  }

  @override
  Future<void> logVideoComplete(String videoId, int totalTime) async {
    _logMockEvent('video_complete', {
      'video_id': videoId,
      'total_time_seconds': totalTime,
    });
  }

  @override
  Future<void> logQuizStart(String quizId) async {
    _logMockEvent('quiz_start', {
      'quiz_id': quizId,
    });
  }

  @override
  Future<void> logQuizComplete(String quizId, int score, int totalQuestions) async {
    _logMockEvent('quiz_complete', {
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'percentage': ((score / totalQuestions) * 100).round(),
    });
  }

  @override
  Future<void> logPostCreate(String postId, String category) async {
    _logMockEvent('post_create', {
      'post_id': postId,
      'category': category,
    });
  }

  @override
  Future<void> logPostView(String postId) async {
    _logMockEvent('post_view', {
      'post_id': postId,
    });
  }

  @override
  Future<void> logPostLike(String postId) async {
    _logMockEvent('post_like', {
      'post_id': postId,
    });
  }

  @override
  Future<void> logPostShare(String postId) async {
    _logMockEvent('post_share', {
      'post_id': postId,
    });
  }

  @override
  Future<void> logError(String errorMessage, {
    String? stackTrace,
    bool? fatal,
  }) async {
    _logMockEvent('app_error', {
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
    _logMockEvent('learning_progress', {
      'course_id': courseId,
      'completed_lessons': completedLessons,
      'total_lessons': totalLessons,
      'progress_percentage': progressPercentage,
    });
  }

  @override
  Future<void> logCertificateEarned(String certificateId, String courseId) async {
    _logMockEvent('certificate_earned', {
      'certificate_id': certificateId,
      'course_id': courseId,
    });
  }

  @override
  Future<void> logPageLoadTime(String pageName, int loadTimeMs) async {
    _logMockEvent('page_load_time', {
      'page_name': pageName,
      'load_time_ms': loadTimeMs,
    });
  }

  @override
  Future<void> logAppLaunch(String launchMode) async {
    _logMockEvent('app_launch', {
      'launch_mode': launchMode,
    });
  }

  @override
  Future<void> logAppBackground() async {
    _logMockEvent('app_background', {});
  }

  @override
  Future<void> logAppForeground() async {
    _logMockEvent('app_foreground', {});
  }

  void _logMockEvent(String eventName, Map<String, Object?>? parameters) {
    if (kDebugMode) {
      print('📊 Analytics Event: $eventName');
      if (parameters != null && parameters.isNotEmpty) {
        print('   Parameters: $parameters');
      }
    }
  }
}