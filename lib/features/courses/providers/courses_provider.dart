import 'package:flutter/material.dart';
// Removed old import - using only new model
import '../../../data/models/course_model.dart';
import '../../../services/mock_data_service.dart';
import '../../../services/cache_service.dart';
import '../../../services/sync_service.dart';
import '../../../services/unified_data_service.dart';

class CoursesProvider extends ChangeNotifier {
  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String? _error;
  String _selectedLevel = 'الكل';
  String _selectedCategory = 'الكل';

  // Data services
  final SyncService _syncService = SyncService();
  final UnifiedDataService _unifiedDataService = UnifiedDataService();

  List<CourseModel> get courses => _filteredCourses.isEmpty ? _courses : _filteredCourses;
  CourseModel? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedLevel => _selectedLevel;
  String get selectedCategory => _selectedCategory;

  CoursesProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await CacheService.init();

    // Listen to sync service changes
    _syncService.addListener(_onDataSynced);

    await loadCourses();
  }

  void _onDataSynced() {
    // Update courses when sync service data changes
    final syncedCourses = _syncService.courses;
    if (syncedCourses.isNotEmpty) {
      _courses = syncedCourses;
      _applyCurrentFilters();
      notifyListeners();
      print('DEBUG CoursesProvider: Courses updated from sync service');
    }
  }

  // Removed _convertToCourseModel - sync service already provides the correct model type

  void _applyCurrentFilters() {
    filterCourses(
      level: _selectedLevel != 'الكل' ? _selectedLevel : null,
      category: _selectedCategory != 'الكل' ? _selectedCategory : null,
    );
  }

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('DEBUG CoursesProvider: Starting to load courses...');

      // Force sync to get real data from Firebase
      await _syncService.forceSync();

      // Try to get courses from sync service first (real data)
      if (_syncService.courses.isNotEmpty) {
        _courses = _syncService.courses;
        print('DEBUG CoursesProvider: Loaded ${_courses.length} courses from sync service (REAL DATA)');
      } else {
        // Try unified data service directly
        print('DEBUG CoursesProvider: Sync service empty, trying unified data service directly...');
        final realCourses = await _unifiedDataService.getAllCourses();
        if (realCourses.isNotEmpty) {
          _courses = realCourses;
          print('DEBUG CoursesProvider: Loaded ${_courses.length} courses from unified data service (REAL DATA)');
        } else {
          // Final fallback to mock data if no real data available
          print('DEBUG CoursesProvider: No real data available, using mock data as fallback');
          final mockService = MockDataService();
          final response = await mockService.getCourses();

          if (response['courses'] != null || response['data'] != null) {
            final coursesList = response['courses'] ?? response['data'] ?? [];
            _courses = coursesList as List<CourseModel>;
            print('DEBUG CoursesProvider: Loaded ${_courses.length} courses from mock service (FALLBACK)');
          }
        }
      }

      // Load enrolled courses from cache and update enrollment status
      final enrolledIds = CacheService.getCachedEnrolledCourses();
      if (enrolledIds != null && enrolledIds.isNotEmpty) {
        for (int i = 0; i < _courses.length; i++) {
          if (enrolledIds.contains(_courses[i].id)) {
            _courses[i] = _courses[i].copyWith(isEnrolled: true);
          }
        }
      }

      _filteredCourses = _courses;

      // Cache the courses for consistency
      await CacheService.cacheCourses(_courses);
      print('DEBUG CoursesProvider: Cached courses successfully');

    } catch (e) {
      print('DEBUG CoursesProvider: Error loading courses: $e');
      _error = 'فشل تحميل الدورات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshCoursesFromServer({String? category}) async {
    try {
      print('DEBUG CoursesProvider: Refreshing courses from server...');

      // Force sync with the unified data service
      await _syncService.forceSync();

      // Get the updated courses from sync service first
      if (_syncService.courses.isNotEmpty) {
        _courses = _syncService.courses;
        print('DEBUG CoursesProvider: Refreshed ${_courses.length} courses from sync service (REAL DATA)');
      } else {
        // Try unified data service directly
        print('DEBUG CoursesProvider: Sync service empty, trying unified data service for refresh...');
        final realCourses = await _unifiedDataService.getAllCourses();
        if (realCourses.isNotEmpty) {
          _courses = realCourses;
          print('DEBUG CoursesProvider: Refreshed ${_courses.length} courses from unified data service (REAL DATA)');
        } else {
          throw Exception('No real data available from Firebase');
        }
      }

      // Apply category filter if specified
      if (category != null && category != 'الكل') {
        _courses = _courses.where((c) => c.category == category).toList();
        print('DEBUG CoursesProvider: Applied category filter: $category, ${_courses.length} courses remaining');
      }

      _filteredCourses = _courses;

      await CacheService.cacheCourses(_courses);
      await CacheService.updateLastSync();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('ERROR CoursesProvider: Failed to refresh from real data: $e');

      // Final fallback to mock service only if real data completely fails
      try {
        print('DEBUG CoursesProvider: Using mock data as final fallback for refresh');
        final mockService = MockDataService();
        final response = await mockService.getCourses(category: category);

        if (response['courses'] != null || response['data'] != null) {
          final coursesList = response['courses'] ?? response['data'] ?? [];
          _courses = coursesList as List<CourseModel>;
          _filteredCourses = _courses;

          await CacheService.cacheCourses(_courses);
          await CacheService.updateLastSync();
          print('DEBUG CoursesProvider: Refreshed ${_courses.length} courses from mock service (FALLBACK)');
        }
      } catch (mockError) {
        print('ERROR CoursesProvider: Mock service also failed: $mockError');
        _error = 'فشل تحديث الدورات';
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  void filterCourses({String? level, String? category, String? searchQuery}) {
    print('DEBUG filterCourses called - level: $level, category: $category, searchQuery: $searchQuery');
    print('DEBUG Available courses levels: ${_courses.map((c) => c.level).toSet()}');

    _filteredCourses = _courses.where((course) {
      bool matchesLevel = level == null || level == 'الكل' || course.level == level;
      bool matchesCategory = category == null || category == 'الكل' || course.category == category;
      bool matchesSearch = searchQuery == null ||
          searchQuery.isEmpty ||
          course.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          course.description.toLowerCase().contains(searchQuery.toLowerCase());

      if (level != null && level != 'الكل') {
        print('DEBUG Checking course ${course.title} with level ${course.level} against filter $level: $matchesLevel');
      }

      return matchesLevel && matchesCategory && matchesSearch;
    }).toList();

    print('DEBUG Filtered courses count: ${_filteredCourses.length}');

    if (level != null) _selectedLevel = level;
    if (category != null) _selectedCategory = category;

    notifyListeners();
  }

  Future<void> loadCoursesByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    if (category == 'الكل') {
      await loadCourses();
    } else {
      // Filter mock data by category
      filterCourses(category: category);
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectCourse(String courseId) {
    _selectedCourse = _courses.firstWhere(
      (course) => course.id == courseId,
      orElse: () => _courses.first,
    );
    
    // Add to recently viewed
    CacheService.addToRecentlyViewed(courseId);
    
    notifyListeners();
  }

  Future<Map<String, dynamic>?> enrollInCourse(String courseId, [String? userId]) async {
    try {
      // Try to use real enrollment through sync service first
      if (userId != null) {
        await _syncService.enrollUserInCourse(userId, courseId);

        // Update local state
        final courseIndex = _courses.indexWhere((c) => c.id == courseId);
        if (courseIndex != -1) {
          _courses[courseIndex] = _courses[courseIndex].copyWith(
            enrolledStudents: _courses[courseIndex].enrolledStudents + 1,
            isEnrolled: true,
          );

          // Update cached enrolled courses
          final enrolledIds = CacheService.getCachedEnrolledCourses() ?? [];
          if (!enrolledIds.contains(courseId)) {
            enrolledIds.add(courseId);
            await CacheService.cacheEnrolledCourses(enrolledIds);
          }

          notifyListeners();
        }

        return {'success': true, 'message': 'تم التسجيل في الدورة بنجاح'};
      } else {
        // Fallback to mock service
        final mockService = MockDataService();
        final response = await mockService.enrollInCourse(courseId);

        // Check if it's a paid course (402 status)
        if (response['success'] == false && response['error'] != null && response['error'].toString().contains('paid course')) {
          throw Exception('402: ${response['error']}');
        }

        // Update local state only if enrollment is successful
        if (response['success'] == true) {
          final courseIndex = _courses.indexWhere((c) => c.id == courseId);
          if (courseIndex != -1) {
            _courses[courseIndex] = _courses[courseIndex].copyWith(
              enrolledStudents: _courses[courseIndex].enrolledStudents + 1,
              isEnrolled: true,
            );

            // Update cached enrolled courses
            final enrolledIds = CacheService.getCachedEnrolledCourses() ?? [];
            if (!enrolledIds.contains(courseId)) {
              enrolledIds.add(courseId);
              await CacheService.cacheEnrolledCourses(enrolledIds);
            }

            notifyListeners();
          }
        }

        return response;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

}