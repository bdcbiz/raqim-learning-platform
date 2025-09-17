import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressService extends ChangeNotifier {
  SharedPreferences? _prefs;
  Map<String, Map<String, dynamic>> _courseProgress = {};
  Map<String, List<String>> _completedLessons = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  ProgressService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProgressFromStorage();
  }

  void _loadProgressFromStorage() {
    // Load course progress from local storage
    final progressJson = _prefs?.getString('course_progress');
    if (progressJson != null) {
      final decoded = json.decode(progressJson) as Map<String, dynamic>;
      _courseProgress = decoded.map((key, value) =>
        MapEntry(key, Map<String, dynamic>.from(value)));
    }

    // Load completed lessons from local storage
    final lessonsJson = _prefs?.getString('completed_lessons');
    if (lessonsJson != null) {
      final decoded = json.decode(lessonsJson) as Map<String, dynamic>;
      _completedLessons = decoded.map((key, value) =>
        MapEntry(key, List<String>.from(value)));
    }
  }

  Future<void> _saveProgressToStorage() async {
    await _prefs?.setString('course_progress', json.encode(_courseProgress));
    await _prefs?.setString('completed_lessons', json.encode(_completedLessons));
  }

  // Get progress for a specific course
  Future<Map<String, dynamic>?> getCourseProgress(String userId, String courseId) async {
    final key = '${userId}_$courseId';

    if (_courseProgress.containsKey(key)) {
      return _courseProgress[key];
    }

    // Initialize new progress if not exists
    _courseProgress[key] = {
      'courseId': courseId,
      'userId': userId,
      'progressPercentage': 0,
      'completedLessons': [],
      'lastAccessedAt': DateTime.now().toIso8601String(),
      'isCompleted': false,
    };

    await _saveProgressToStorage();
    return _courseProgress[key];
  }

  // Mark a lesson as complete
  Future<void> markLessonComplete(String userId, String courseId, String lessonId) async {
    final key = '${userId}_$courseId';

    // Initialize if not exists
    if (!_completedLessons.containsKey(key)) {
      _completedLessons[key] = [];
    }

    if (!_completedLessons[key]!.contains(lessonId)) {
      _completedLessons[key]!.add(lessonId);

      // Update progress
      if (!_courseProgress.containsKey(key)) {
        _courseProgress[key] = {
          'courseId': courseId,
          'userId': userId,
          'progressPercentage': 0,
          'completedLessons': [],
          'lastAccessedAt': DateTime.now().toIso8601String(),
          'isCompleted': false,
        };
      }

      _courseProgress[key]!['completedLessons'] = _completedLessons[key];
      _courseProgress[key]!['lastAccessedLesson'] = lessonId;
      _courseProgress[key]!['lastAccessedAt'] = DateTime.now().toIso8601String();

      // Calculate progress percentage (assuming 10 lessons per course for demo)
      final completedCount = _completedLessons[key]!.length;
      _courseProgress[key]!['progressPercentage'] = (completedCount * 10).clamp(0, 100);

      if (completedCount >= 10) {
        _courseProgress[key]!['isCompleted'] = true;
      }

      await _saveProgressToStorage();
      notifyListeners();
    }
  }

  // Check if a lesson is completed
  bool isLessonCompleted(String userId, String courseId, String lessonId) {
    final key = '${userId}_$courseId';
    return _completedLessons[key]?.contains(lessonId) ?? false;
  }

  // Get progress percentage for a course
  int getProgressPercentage(String userId, String courseId) {
    final key = '${userId}_$courseId';
    return _courseProgress[key]?['progressPercentage'] ?? 0;
  }

  // Get all completed lessons for a course
  List<String> getCompletedLessons(String userId, String courseId) {
    final key = '${userId}_$courseId';
    return _completedLessons[key] ?? [];
  }

  // Get last accessed lesson
  String? getLastAccessedLesson(String userId, String courseId) {
    final key = '${userId}_$courseId';
    return _courseProgress[key]?['lastAccessedLesson'];
  }

  // Check if course is completed
  bool isCourseCompleted(String userId, String courseId) {
    final key = '${userId}_$courseId';
    return _courseProgress[key]?['isCompleted'] ?? false;
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    int enrolledCourses = 0;
    int completedCourses = 0;
    double totalProgress = 0;

    _courseProgress.forEach((key, progress) {
      if (key.startsWith(userId)) {
        enrolledCourses++;
        if (progress['isCompleted'] == true) {
          completedCourses++;
        }
        totalProgress += (progress['progressPercentage'] ?? 0);
      }
    });

    return {
      'enrolledCourses': enrolledCourses,
      'completedCourses': completedCourses,
      'certificates': completedCourses, // Assume certificate for each completed course
      'totalLearningHours': (totalProgress * 0.5).round(), // Mock calculation
      'currentStreak': 7, // Mock streak
    };
  }

  // Calculate total progress across all courses
  double getTotalProgress(String userId, List<String> courseIds) {
    if (courseIds.isEmpty) return 0.0;

    double totalProgress = 0;
    for (String courseId in courseIds) {
      totalProgress += getProgressPercentage(userId, courseId);
    }

    return totalProgress / courseIds.length;
  }

  // Get recently accessed courses
  List<Map<String, dynamic>> getRecentlyAccessedCourses(String userId, {int limit = 5}) {
    final recentCourses = <Map<String, dynamic>>[];

    _courseProgress.forEach((key, progress) {
      if (key.startsWith(userId)) {
        final courseId = key.split('_')[1];
        if (progress['lastAccessedAt'] != null) {
          recentCourses.add({
            'courseId': courseId,
            'lastAccessedAt': progress['lastAccessedAt'],
            'progressPercentage': progress['progressPercentage'] ?? 0,
            'lastAccessedLesson': progress['lastAccessedLesson'],
          });
        }
      }
    });

    // Sort by last accessed date
    recentCourses.sort((a, b) {
      final dateA = DateTime.parse(a['lastAccessedAt'].toString());
      final dateB = DateTime.parse(b['lastAccessedAt'].toString());
      return dateB.compareTo(dateA);
    });

    return recentCourses.take(limit).toList();
  }

  // Clear cached progress (useful when user logs out)
  void clearProgress() {
    _courseProgress.clear();
    _completedLessons.clear();
    _prefs?.remove('course_progress');
    _prefs?.remove('completed_lessons');
    notifyListeners();
  }
}