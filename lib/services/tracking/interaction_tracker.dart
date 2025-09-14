import 'package:flutter/foundation.dart';
import '../database/firestore_service.dart';
import '../auth/auth_interface.dart';

class InteractionTracker {
  static final InteractionTracker _instance = InteractionTracker._internal();
  factory InteractionTracker() => _instance;
  InteractionTracker._internal();

  final FirestoreService _firestoreService = FirestoreService();
  AuthServiceInterface? _authService;

  void initialize(AuthServiceInterface authService) {
    _authService = authService;
  }

  String? get _currentUserId => _authService?.currentUser?.id;
  String? get _currentUserEmail => _authService?.currentUser?.email;

  Future<void> trackPageView(String pageName, {Map<String, dynamic>? additionalData}) async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: 'page_view',
      details: {
        'page': pageName,
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  Future<void> trackButtonClick(String buttonName, {Map<String, dynamic>? additionalData}) async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: 'button_click',
      details: {
        'button': buttonName,
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  Future<void> trackCourseAction(String action, String courseId, {Map<String, dynamic>? additionalData}) async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: 'course_$action',
      details: {
        'courseId': courseId,
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  Future<void> trackLessonProgress(String lessonId, int progress, {Map<String, dynamic>? additionalData}) async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: 'lesson_progress',
      details: {
        'lessonId': lessonId,
        'progress': progress,
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  Future<void> trackSearch(String query, {Map<String, dynamic>? additionalData}) async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: 'search',
      details: {
        'query': query,
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  Future<void> trackLogin(String method) async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: 'login',
      details: {
        'method': method,
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': kIsWeb ? 'web' : 'mobile',
      },
    );
  }

  Future<void> trackLogout() async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: 'logout',
      details: {
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': kIsWeb ? 'web' : 'mobile',
      },
    );
  }

  Future<void> trackRegistration(String method) async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: 'registration',
      details: {
        'method': method,
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': kIsWeb ? 'web' : 'mobile',
      },
    );
  }

  Future<void> trackError(String error, String context, {Map<String, dynamic>? additionalData}) async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: 'error',
      details: {
        'error': error,
        'context': context,
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  Future<void> trackCustomEvent(String eventName, Map<String, dynamic> eventData) async {
    if (_currentUserId == null) return;

    await _firestoreService.trackInteraction(
      userId: _currentUserId!,
      action: eventName,
      details: {
        'userEmail': _currentUserEmail,
        'timestamp': DateTime.now().toIso8601String(),
        ...eventData,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getUserInteractions({int limit = 50}) async {
    if (_currentUserId == null) return [];
    return await _firestoreService.getUserInteractions(_currentUserId!, limit: limit);
  }

  Stream<List<Map<String, dynamic>>> streamUserInteractions() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    return _firestoreService.streamUserInteractions(_currentUserId!);
  }

  Future<Map<String, dynamic>> getUserStats() async {
    if (_currentUserId == null) {
      return {
        'totalInteractions': 0,
        'actionCounts': {},
        'lastInteraction': null,
      };
    }
    return await _firestoreService.getUserStats(_currentUserId!);
  }
}