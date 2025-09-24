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
    // First try to find in filtered courses (sample data)
    CourseModel? foundCourse;

    // Check in filtered courses first (includes sample data)
    if (_filteredCourses.isNotEmpty) {
      try {
        foundCourse = _filteredCourses.firstWhere((course) => course.id == courseId);
      } catch (e) {
        // Course not found in filtered courses
      }
    }

    // If not found, check in all courses
    if (foundCourse == null && _courses.isNotEmpty) {
      try {
        foundCourse = _courses.firstWhere((course) => course.id == courseId);
      } catch (e) {
        // Course not found in all courses
      }
    }

    // If still not found, create a mock course with the given ID
    if (foundCourse == null) {
      foundCourse = _createMockCourseById(courseId);
    }

    _selectedCourse = foundCourse;

    // Add to recently viewed
    CacheService.addToRecentlyViewed(courseId);

    notifyListeners();
  }

  CourseModel _createMockCourseById(String courseId) {
    // Create mock courses that match the sample data from courses_list_screen.dart
    final mockCourses = {
      'sample-1': CourseModel(
        id: 'sample-1',
        title: 'مقدمة في تعلم الآلة',
        description: 'دورة شاملة لتعلم أساسيات الذكاء الاصطناعي وتعلم الآلة من الصفر. ستتعلم المفاهيم الأساسية والتطبيقات العملية.',
        thumbnailUrl: 'https://picsum.photos/400/300?random=31',
        instructorId: 'instructor-1',
        instructorName: 'د. أحمد الرشيد',
        instructorBio: 'خبير في الذكاء الاصطناعي مع أكثر من 10 سنوات من الخبرة',
        level: 'مبتدئ',
        category: 'تعلم الآلة',
        objectives: [
          'فهم المفاهيم الأساسية لتعلم الآلة',
          'تطبيق خوارزميات التعلم المختلفة',
          'بناء مشاريع عملية'
        ],
        requirements: [
          'معرفة أساسية بالرياضيات',
          'خبرة بسيطة في البرمجة'
        ],
        price: 299.0,
        rating: 4.8,
        totalRatings: 245,
        enrolledStudents: 1250,
        totalDuration: Duration(hours: 40),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFree: false,
        language: 'ar',
        modules: [],
        reviews: [],
        isEnrolled: false,
      ),
      'sample-2': CourseModel(
        id: 'sample-2',
        title: 'أساسيات معالجة اللغة الطبيعية',
        description: 'تعلم كيفية معالجة النصوص والتعامل مع اللغة الطبيعية باستخدام تقنيات الذكاء الاصطناعي الحديثة.',
        thumbnailUrl: 'https://picsum.photos/400/300?random=32',
        instructorId: 'instructor-2',
        instructorName: 'د. سارة جونسون',
        instructorBio: 'متخصصة في معالجة اللغات الطبيعية والذكاء الاصطناعي',
        level: 'متوسط',
        category: 'معالجة اللغات',
        objectives: [
          'فهم تقنيات معالجة النصوص',
          'تطبيق خوارزميات NLP',
          'بناء تطبيقات ذكية للنصوص'
        ],
        requirements: [
          'معرفة أساسية بتعلم الآلة',
          'خبرة في Python'
        ],
        price: 599.0,
        rating: 4.9,
        totalRatings: 189,
        enrolledStudents: 890,
        totalDuration: Duration(hours: 50),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFree: false,
        language: 'ar',
        modules: [],
        reviews: [],
        isEnrolled: false,
      ),
      'sample-3': CourseModel(
        id: 'sample-3',
        title: 'الرؤية الحاسوبية والتعلم العميق',
        description: 'دورة متقدمة في الرؤية الحاسوبية باستخدام تقنيات التعلم العميق والشبكات العصبية.',
        thumbnailUrl: 'https://picsum.photos/400/300?random=33',
        instructorId: 'instructor-3',
        instructorName: 'أ.د. عمر حسان',
        instructorBio: 'أستاذ الذكاء الاصطناعي والرؤية الحاسوبية',
        level: 'متقدم',
        category: 'رؤية الحاسوب',
        objectives: [
          'إتقان تقنيات الرؤية الحاسوبية',
          'تطبيق الشبكات العصبية العميقة',
          'تطوير تطبيقات متقدمة'
        ],
        requirements: [
          'خبرة قوية في تعلم الآلة',
          'معرفة بالرياضيات المتقدمة'
        ],
        price: 799.0,
        rating: 4.7,
        totalRatings: 156,
        enrolledStudents: 650,
        totalDuration: Duration(hours: 60),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFree: false,
        language: 'ar',
        modules: [],
        reviews: [],
        isEnrolled: false,
      ),
    };

    return mockCourses[courseId] ?? CourseModel(
      id: courseId,
      title: 'دورة تعليمية',
      description: 'وصف الدورة غير متوفر حالياً',
      thumbnailUrl: 'https://picsum.photos/400/300?random=1',
      instructorId: 'default-instructor',
      instructorName: 'مدرب معتمد',
      instructorBio: '',
      level: 'مبتدئ',
      category: 'عام',
      objectives: ['تعلم مهارات جديدة'],
      requirements: ['لا توجد متطلبات خاصة'],
      price: 0.0,
      rating: 4.5,
      totalRatings: 100,
      enrolledStudents: 500,
      totalDuration: Duration(hours: 20),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFree: true,
      language: 'ar',
      modules: [],
      reviews: [],
      isEnrolled: false,
    );
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