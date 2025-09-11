import 'package:flutter/material.dart';
import '../../../data/models/course_model.dart';
import '../../../services/api_service.dart';
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
      // Try to load from cache first
      final cachedCourses = CacheService.getCachedCourses();
      if (cachedCourses != null && cachedCourses.isNotEmpty) {
        _courses = cachedCourses;
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
        
        _isLoading = false;
        notifyListeners();
        
        // Refresh from server in background if needed
        if (CacheService.shouldRefreshCache()) {
          await _refreshCoursesFromServer();
        }
      } else {
        // No cache, load from server
        await _refreshCoursesFromServer();
      }
    } catch (e) {
      // On error, use mock data
      _courses = _generateMockCourses();
      _filteredCourses = _courses;
      
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshCoursesFromServer() async {
    try {
      final response = await ApiService.getCourses();
      
      if (response['courses'] != null) {
        _courses = (response['courses'] as List)
            .map((json) => CourseModel.fromJson(json))
            .toList();
            
        // Cache the courses
        await CacheService.cacheCourses(_courses);
        
        // Get enrolled courses and cache them
        try {
          final enrolledResponse = await ApiService.getEnrolledCourses();
          if (enrolledResponse['courses'] != null) {
            final enrolledIds = (enrolledResponse['courses'] as List)
                .map((course) => course['_id']?.toString() ?? course['id']?.toString() ?? '')
                .where((id) => id.isNotEmpty)
                .toList();
            
            await CacheService.cacheEnrolledCourses(enrolledIds);
            
            // Mark enrolled courses
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
        } catch (enrollError) {
          print('Error loading enrolled courses: $enrollError');
        }
        
        await CacheService.updateLastSync();
      } else {
        // Fallback to mock data if API returns empty
        _courses = _generateMockCourses();
      }
      
      _filteredCourses = _courses;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      throw e;
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
      // Call the API to enroll in the course
      final response = await ApiService.enrollInCourse(courseId);
      
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

  List<CourseModel> _generateMockCourses() {
    return [
      CourseModel(
        id: '1',
        title: 'أساسيات تعلم الآلة للمبتدئين',
        description: 'تعلم أساسيات الذكاء الاصطناعي وتعلم الآلة من الصفر. دورة شاملة تغطي جميع المفاهيم الأساسية.',
        thumbnailUrl: 'https://picsum.photos/seed/ml1/400/225',
        promoVideoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        instructorId: '1',
        instructorName: 'د. أحمد محمد',
        instructorBio: 'خبير في مجال الذكاء الاصطناعي مع خبرة 10 سنوات',
        instructorPhotoUrl: 'https://picsum.photos/150/150',
        level: 'مبتدئ',
        category: 'تعلم الآلة',
        isEnrolled: true, // User is enrolled
        objectives: [
          'فهم أساسيات تعلم الآلة',
          'بناء نماذج بسيطة',
          'تطبيق الخوارزميات الأساسية',
        ],
        requirements: ['معرفة أساسية بالبرمجة', 'رغبة في التعلم'],
        modules: [
          CourseModule(
            id: 'm1',
            title: 'مقدمة في تعلم الآلة',
            lessons: [
              Lesson(
                id: 'l1',
                title: 'ما هو تعلم الآلة؟',
                videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                duration: const Duration(minutes: 15),
              ),
              Lesson(
                id: 'l2',
                title: 'أنواع تعلم الآلة',
                videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                duration: const Duration(minutes: 20),
              ),
            ],
            duration: const Duration(minutes: 35),
          ),
        ],
        price: 0,
        rating: 4.8,
        totalRatings: 1250,
        enrolledStudents: 5432,
        totalDuration: const Duration(hours: 12),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        isFree: true,
      ),
      CourseModel(
        id: '2',
        title: 'معالجة اللغات الطبيعية المتقدمة',
        description: 'دورة متقدمة في معالجة اللغات الطبيعية باستخدام أحدث التقنيات والنماذج.',
        thumbnailUrl: 'https://picsum.photos/seed/nlp2/400/225',
        instructorId: '2',
        instructorName: 'د. سارة أحمد',
        instructorBio: 'باحثة في مجال NLP مع خبرة 8 سنوات',
        level: 'متقدم',
        category: 'معالجة اللغات الطبيعية',
        objectives: [
          'فهم النماذج المتقدمة في NLP',
          'بناء تطبيقات معقدة',
          'استخدام Transformers',
        ],
        requirements: ['خبرة في Python', 'معرفة بأساسيات NLP'],
        modules: [],
        price: 299,
        rating: 4.9,
        totalRatings: 342,
        enrolledStudents: 1234,
        totalDuration: const Duration(hours: 25),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      CourseModel(
        id: '3',
        title: 'رؤية الحاسوب والتعلم العميق',
        description: 'تعلم كيفية بناء أنظمة رؤية الحاسوب باستخدام الشبكات العصبية العميقة.',
        thumbnailUrl: 'https://picsum.photos/seed/cv3/400/225',
        instructorId: '3',
        instructorName: 'م. خالد عبدالله',
        instructorBio: 'مهندس ذكاء اصطناعي في شركة تقنية رائدة',
        level: 'متوسط',
        category: 'رؤية الحاسوب',
        objectives: [
          'فهم CNN و شبكات التصنيف',
          'بناء أنظمة كشف الأجسام',
          'تطبيقات عملية في الصور والفيديو',
        ],
        requirements: ['معرفة بـ Python', 'أساسيات تعلم الآلة'],
        modules: [],
        price: 199,
        rating: 4.7,
        totalRatings: 567,
        enrolledStudents: 2341,
        totalDuration: const Duration(hours: 18),
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
      CourseModel(
        id: '4',
        title: 'Python للذكاء الاصطناعي - مجاني',
        description: 'تعلم برمجة Python من الصفر مع التركيز على تطبيقات الذكاء الاصطناعي. دورة مجانية شاملة للمبتدئين.',
        thumbnailUrl: 'https://picsum.photos/seed/python4/400/225',
        instructorId: '1',
        instructorName: 'د. أحمد محمد',
        instructorBio: 'خبير في مجال الذكاء الاصطناعي مع خبرة 10 سنوات',
        level: 'مبتدئ',
        category: 'البرمجة',
        objectives: [
          'أساسيات لغة Python',
          'المكتبات الأساسية للذكاء الاصطناعي',
          'بناء مشاريع عملية',
        ],
        requirements: ['لا توجد متطلبات سابقة'],
        modules: [],
        price: 0,
        rating: 4.6,
        totalRatings: 892,
        enrolledStudents: 8765,
        totalDuration: const Duration(hours: 15),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        isFree: true,
      ),
      CourseModel(
        id: '5',
        title: 'الذكاء الاصطناعي التوليدي وChatGPT',
        description: 'اكتشف عالم الذكاء الاصطناعي التوليدي وتعلم كيفية استخدام ChatGPT وأدوات AI الحديثة.',
        thumbnailUrl: 'https://picsum.photos/seed/gpt5/400/225',
        instructorId: '2',
        instructorName: 'د. سارة أحمد',
        instructorBio: 'باحثة في مجال NLP مع خبرة 8 سنوات',
        level: 'متوسط',
        category: 'الذكاء الاصطناعي التوليدي',
        objectives: [
          'فهم تقنيات GPT وLLMs',
          'بناء تطبيقات باستخدام APIs',
          'Prompt Engineering احترافي',
        ],
        requirements: ['معرفة أساسية بالبرمجة'],
        modules: [],
        price: 149,
        rating: 4.9,
        totalRatings: 623,
        enrolledStudents: 3421,
        totalDuration: const Duration(hours: 10),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      CourseModel(
        id: '6',
        title: 'بناء تطبيقات الذكاء الاصطناعي بـ TensorFlow',
        description: 'دورة عملية متقدمة لبناء وتدريب نماذج الذكاء الاصطناعي باستخدام TensorFlow و Keras.',
        thumbnailUrl: 'https://picsum.photos/seed/tf6/400/225',
        instructorId: '3',
        instructorName: 'م. خالد عبدالله',
        instructorBio: 'مهندس ذكاء اصطناعي في شركة تقنية رائدة',
        level: 'متقدم',
        category: 'التعلم العميق',
        objectives: [
          'إتقان TensorFlow و Keras',
          'بناء نماذج متقدمة',
          'نشر النماذج في الإنتاج',
        ],
        requirements: ['خبرة في Python', 'معرفة بأساسيات ML'],
        modules: [],
        price: 399,
        rating: 4.8,
        totalRatings: 234,
        enrolledStudents: 876,
        totalDuration: const Duration(hours: 30),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      CourseModel(
        id: '7',
        title: 'مقدمة في علم البيانات - مجاني',
        description: 'ابدأ رحلتك في علم البيانات مع هذه الدورة المجانية الشاملة. تعلم التحليل والتصور والإحصاء.',
        thumbnailUrl: 'https://picsum.photos/seed/ds7/400/225',
        instructorId: '1',
        instructorName: 'د. أحمد محمد',
        instructorBio: 'خبير في مجال الذكاء الاصطناعي مع خبرة 10 سنوات',
        level: 'مبتدئ',
        category: 'علم البيانات',
        objectives: [
          'أساسيات تحليل البيانات',
          'التصور باستخدام Python',
          'الإحصاء الوصفي والاستدلالي',
        ],
        requirements: ['معرفة أساسية بالرياضيات'],
        modules: [],
        price: 0,
        rating: 4.5,
        totalRatings: 1567,
        enrolledStudents: 12345,
        totalDuration: const Duration(hours: 20),
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now(),
        isFree: true,
      ),
      CourseModel(
        id: '8',
        title: 'الذكاء الاصطناعي في الأعمال',
        description: 'تعلم كيفية تطبيق الذكاء الاصطناعي في بيئة الأعمال وزيادة الإنتاجية وتحسين اتخاذ القرار.',
        thumbnailUrl: 'https://picsum.photos/seed/biz8/400/225',
        instructorId: '2',
        instructorName: 'د. سارة أحمد',
        instructorBio: 'باحثة في مجال NLP مع خبرة 8 سنوات',
        level: 'متوسط',
        category: 'الأعمال',
        objectives: [
          'استراتيجيات AI للأعمال',
          'أتمتة العمليات',
          'تحليل البيانات للقرارات',
        ],
        requirements: ['خبرة في مجال الأعمال'],
        modules: [],
        price: 249,
        rating: 4.7,
        totalRatings: 432,
        enrolledStudents: 2134,
        totalDuration: const Duration(hours: 12),
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}