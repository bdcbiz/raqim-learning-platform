import 'package:flutter/material.dart';
import '../../../data/models/course_model.dart';
import '../../../services/mock_data_service.dart';
import '../../../services/cache_service.dart';

class CoursesProvider extends ChangeNotifier {
  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String? _error;
  String _selectedLevel = 'الكل';
  String _selectedCategory = 'الكل';

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
    await loadCourses();
  }

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use mock data service for now
      final mockService = MockDataService();
      final response = await mockService.getCourses();

      if (response['courses'] != null || response['data'] != null) {
        final coursesList = response['courses'] ?? response['data'] ?? [];
        _courses = coursesList as List<CourseModel>;
        _filteredCourses = _courses;

      // Load enrolled courses from cache
      final enrolledIds = CacheService.getCachedEnrolledCourses();
      if (enrolledIds != null) {
        for (var course in _courses) {
          if (enrolledIds.contains(course.id)) {
            final index = _courses.indexOf(course);
            _courses[index] = CourseModel(
                id: course.id,
                title: course.title,
                description: course.description,
                thumbnailUrl: course.thumbnailUrl,
                promoVideoUrl: course.promoVideoUrl,
                instructorId: course.instructorId,
                instructorName: course.instructorName,
                instructorBio: course.instructorBio,
                instructorPhotoUrl: course.instructorPhotoUrl,
                level: course.level,
                category: course.category,
                objectives: course.objectives,
                requirements: course.requirements,
                modules: course.modules,
                price: course.price,
                rating: course.rating,
                totalRatings: course.totalRatings,
                enrolledStudents: course.enrolledStudents,
                totalDuration: course.totalDuration,
                createdAt: course.createdAt,
                updatedAt: course.updatedAt,
                isFree: course.isFree,
                language: course.language,
                reviews: course.reviews,
                isEnrolled: true,
              );
            }
          }
        }

        // Cache the courses for consistency
        await CacheService.cacheCourses(_courses);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading courses: $e');
      _error = 'فشل تحميل الدورات';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshCoursesFromServer({String? category}) async {
    try {
      final mockService = MockDataService();
      final response = await mockService.getCourses(category: category);

      if (response['courses'] != null || response['data'] != null) {
        final coursesList = response['courses'] ?? response['data'] ?? [];
        _courses = coursesList as List<CourseModel>;
        _filteredCourses = _courses;

        await CacheService.cacheCourses(_courses);
        await CacheService.updateLastSync();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error refreshing courses: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterCourses({String? level, String? category, String? searchQuery}) {
    _filteredCourses = _courses.where((course) {
      bool matchesLevel = level == null || level == 'الكل' || course.level == level;
      bool matchesCategory = category == null || category == 'الكل' || course.category == category;
      bool matchesSearch = searchQuery == null || 
          searchQuery.isEmpty || 
          course.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          course.description.toLowerCase().contains(searchQuery.toLowerCase());
      
      return matchesLevel && matchesCategory && matchesSearch;
    }).toList();
    
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

  Future<Map<String, dynamic>?> enrollInCourse(String courseId) async {
    try {
      // Use mock data service
      final mockService = MockDataService();
      final response = await mockService.enrollInCourse(courseId);
      
      // Check if it's a paid course (402 status)
      if (response['success'] == false && response['error'] != null && response['error'].toString().contains('paid course')) {
        // Throw error with the response details for the UI to handle
        throw Exception('402: ${response['error']}');
      }
      
      // Update local state only if enrollment is successful
      if (response['success'] == true) {
        final courseIndex = _courses.indexWhere((c) => c.id == courseId);
        if (courseIndex != -1) {
          final course = _courses[courseIndex];
          _courses[courseIndex] = CourseModel(
            id: course.id,
            title: course.title,
            description: course.description,
            thumbnailUrl: course.thumbnailUrl,
            promoVideoUrl: course.promoVideoUrl,
            instructorId: course.instructorId,
            instructorName: course.instructorName,
            instructorBio: course.instructorBio,
            instructorPhotoUrl: course.instructorPhotoUrl,
            level: course.level,
            category: course.category,
            objectives: course.objectives,
            requirements: course.requirements,
            modules: course.modules,
            price: course.price,
            rating: course.rating,
            totalRatings: course.totalRatings,
            enrolledStudents: course.enrolledStudents + 1,
            totalDuration: course.totalDuration,
            createdAt: course.createdAt,
            updatedAt: course.updatedAt,
            isFree: course.isFree,
            language: course.language,
            reviews: course.reviews,
            isEnrolled: true, // Mark as enrolled
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
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw to let the calling widget handle the error
    }
  }

}