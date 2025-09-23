import 'package:flutter/material.dart';
import '../../../data/models/course_model.dart';
import '../../../services/api/api_service.dart';
import '../../../services/cache_service.dart';

class CoursesProvider extends ChangeNotifier {
  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String? _error;
  String _selectedLevel = 'الكل';
  String _selectedCategory = 'الكل';

  final ApiService _apiService = ApiService.instance;

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
    await _apiService.initialize();
    await loadCourses();
  }

  void _applyCurrentFilters() {
    filterCourses(
      level: _selectedLevel != 'الكل' ? _selectedLevel : null,
      category: _selectedCategory != 'الكل' ? _selectedCategory : null,
    );
  }

  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('DEBUG CoursesProvider: Loading courses from Laravel API...');

      // Get courses from Laravel API
      final response = await _apiService.get('/courses');

      if (response['data'] != null) {
        final coursesData = response['data'] as List;
        _courses = coursesData.map((courseJson) => _convertApiResponseToCourseModel(courseJson)).toList();
        print('DEBUG CoursesProvider: Loaded ${_courses.length} courses from Laravel API');
      } else {
        throw Exception('Invalid API response structure');
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

      // Cache the courses
      await CacheService.cacheCourses(_courses);
      print('DEBUG CoursesProvider: Cached courses successfully');

    } catch (e) {
      print('DEBUG CoursesProvider: Error loading courses: $e');
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'فشل تحميل الدورات';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CourseModel _convertApiResponseToCourseModel(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      promoVideoUrl: json['preview_video_url'],
      instructorId: json['instructor']?['_id'] ?? json['instructor_id'] ?? '',
      instructorName: json['instructor']?['name'] ?? 'غير محدد',
      instructorBio: json['instructor']?['bio'] ?? '',
      instructorPhotoUrl: json['instructor']?['avatar'],
      level: json['difficulty_level'] ?? 'مبتدئ',
      category: json['category']?['name'] ?? 'عام',
      objectives: (json['objectives'] as List?)?.map((e) => e.toString()).toList() ?? [],
      requirements: (json['requirements'] as List?)?.map((e) => e.toString()).toList() ?? [],
      modules: [], // Will be loaded separately when needed
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['average_rating'] ?? 0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      enrolledStudents: json['total_enrollments'] ?? 0,
      totalDuration: Duration(hours: int.tryParse(json['duration_hours']?.toString() ?? '1') ?? 1),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isFree: (json['price'] ?? 0) == 0,
      language: json['language'] ?? 'ar',
      reviews: [], // Will be loaded separately when needed
      isEnrolled: false, // Will be updated based on cache
    );
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
    _error = null;
    notifyListeners();

    try {
      if (category == 'الكل') {
        await loadCourses();
      } else {
        // Load courses with category filter from API
        final response = await _apiService.get('/courses', queryParams: {
          'category_id': category,
        });

        if (response['data'] != null) {
          final coursesData = response['data'] as List;
          _courses = coursesData.map((courseJson) => _convertApiResponseToCourseModel(courseJson)).toList();
          _filteredCourses = _courses;
        }
      }
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'فشل تحميل الدورات';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<Map<String, dynamic>?> enrollInCourse(String courseId) async {
    try {
      // Call Laravel API to enroll in course
      final response = await _apiService.post('/enrollments', body: {
        'course_id': courseId,
      });

      if (response['status'] == 'success') {
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

        return {
          'success': true,
          'message': response['message'] ?? 'تم التسجيل في الدورة بنجاح'
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'فشل التسجيل في الدورة'
        };
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();

      if (e is ApiException) {
        return {
          'success': false,
          'message': e.message
        };
      }

      rethrow;
    }
  }

  Future<CourseModel?> getCourseDetails(String courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId');

      if (response['data'] != null) {
        return _convertApiResponseToCourseModel(response['data']);
      }

      return null;
    } catch (e) {
      print('Error getting course details: $e');
      return null;
    }
  }

  Future<List<CourseModel>> getFeaturedCourses() async {
    try {
      final response = await _apiService.get('/courses/featured');

      if (response['data'] != null) {
        final coursesData = response['data'] as List;
        return coursesData.map((courseJson) => _convertApiResponseToCourseModel(courseJson)).toList();
      }

      return [];
    } catch (e) {
      print('Error getting featured courses: $e');
      return [];
    }
  }

  Future<List<CourseModel>> getLatestCourses() async {
    try {
      final response = await _apiService.get('/courses/latest');

      if (response['data'] != null) {
        final coursesData = response['data'] as List;
        return coursesData.map((courseJson) => _convertApiResponseToCourseModel(courseJson)).toList();
      }

      return [];
    } catch (e) {
      print('Error getting latest courses: $e');
      return [];
    }
  }

  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final response = await _apiService.get('/courses/search', queryParams: {
        'q': query,
      });

      if (response['data'] != null && response['data']['courses'] != null) {
        final coursesData = response['data']['courses'] as List;
        return coursesData.map((courseJson) => _convertApiResponseToCourseModel(courseJson)).toList();
      }

      return [];
    } catch (e) {
      print('Error searching courses: $e');
      return [];
    }
  }

}