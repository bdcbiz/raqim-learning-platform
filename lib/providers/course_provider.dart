import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class CourseProvider extends ChangeNotifier {
  List<Course> _allCourses = [];
  List<Course> _enrolledCourses = [];
  bool _isLoading = false;
  String? _error;

  List<Course> get allCourses => _allCourses;
  List<Course> get enrolledCourses => _enrolledCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getCourses();
      if (response['success'] == true) {
        _allCourses = (response['data'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
      } else {
        _error = response['error'] ?? 'Failed to load courses';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEnrolledCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getEnrolledCourses();
      if (response['success'] == true) {
        _enrolledCourses = (response['data'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
      } else {
        _error = response['error'] ?? 'Failed to load enrolled courses';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enrollInCourse(String courseId) async {
    try {
      final response = await ApiService.enrollInCourse(courseId);
      if (response['success'] == true) {
        // Update the course in allCourses list
        final courseIndex = _allCourses.indexWhere((c) => c.id == courseId);
        if (courseIndex != -1) {
          _allCourses[courseIndex] = _allCourses[courseIndex].copyWith(
            isEnrolled: true,
            enrolledAt: DateTime.now().toIso8601String(),
          );
        }
        
        // Add to enrolled courses if not already there
        if (!_enrolledCourses.any((c) => c.id == courseId)) {
          final enrolledCourse = _allCourses.firstWhere(
            (c) => c.id == courseId,
            orElse: () => _allCourses[courseIndex],
          );
          _enrolledCourses.add(enrolledCourse);
        }
        
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Failed to enroll in course';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool isEnrolled(String courseId) {
    return _allCourses.any((c) => c.id == courseId && c.isEnrolled) ||
           _enrolledCourses.any((c) => c.id == courseId);
  }

  Course? getCourseById(String courseId) {
    try {
      return _allCourses.firstWhere((c) => c.id == courseId);
    } catch (e) {
      return null;
    }
  }
}