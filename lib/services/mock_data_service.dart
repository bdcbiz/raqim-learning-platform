import 'dart:async';
import '../data/models/course_model.dart';
import '../data/models/user_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock courses data
  Future<Map<String, dynamic>> getCourses({
    String? category,
    String? level,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    await _simulateDelay();

    List<CourseModel> allCourses = _generateMockCourses();

    // Apply filters
    if (category != null && category != 'الكل') {
      allCourses = allCourses.where((c) => c.category == category).toList();
    }
    if (level != null && level != 'الكل') {
      allCourses = allCourses.where((c) => c.level == level).toList();
    }
    if (search != null && search.isNotEmpty) {
      allCourses = allCourses.where((c) =>
        c.title.toLowerCase().contains(search.toLowerCase()) ||
        c.description.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    // Apply pagination
    int startIndex = (page - 1) * limit;
    int endIndex = startIndex + limit;
    if (endIndex > allCourses.length) endIndex = allCourses.length;

    List<CourseModel> paginatedCourses = allCourses.sublist(
      startIndex < allCourses.length ? startIndex : 0,
      endIndex,
    );

    return {
      'success': true,
      'courses': paginatedCourses,
      'data': paginatedCourses,
      'pagination': {
        'page': page,
        'limit': limit,
        'total': allCourses.length,
        'pages': (allCourses.length / limit).ceil(),
      }
    };
  }

  Future<Map<String, dynamic>> getCourse(String courseId) async {
    await _simulateDelay();

    final courses = _generateMockCourses();
    final course = courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => courses.first,
    );

    return {
      'success': true,
      'course': course,
      'data': course,
    };
  }

  Future<Map<String, dynamic>> getEnrolledCourses() async {
    await _simulateDelay();

    // Return first 3 courses as enrolled
    final courses = _generateMockCourses().take(3).toList();

    return {
      'success': true,
      'courses': courses.map((c) => c.toJson()).toList(),
    };
  }

  Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    await _simulateDelay();

    return {
      'success': true,
      'message': 'تم التسجيل في الدورة بنجاح',
      'data': {
        'courseId': courseId,
        'enrolledAt': DateTime.now().toIso8601String(),
      }
    };
  }

  List<CourseModel> _generateMockCourses() {
    return [
      CourseModel(
        id: '1',
        title: 'أساسيات تعلم الآلة للمبتدئين',
        description: 'تعلم أساسيات الذكاء الاصطناعي وتعلم الآلة من الصفر. دورة شاملة تغطي جميع المفاهيم الأساسية.',
        thumbnailUrl: 'https://picsum.photos/400/225?random=1',
        promoVideoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        instructorId: '1',
        instructorName: 'د. أحمد محمد',
        instructorBio: 'خبير في مجال الذكاء الاصطناعي مع خبرة 10 سنوات',
        instructorPhotoUrl: 'https://picsum.photos/150/150?random=1',
        level: 'مبتدئ',
        category: 'تعلم الآلة',
        isEnrolled: true,
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
        thumbnailUrl: 'https://picsum.photos/400/225?random=2',
        instructorId: '2',
        instructorName: 'د. سارة أحمد',
        instructorBio: 'باحثة في مجال NLP مع خبرة 8 سنوات',
        level: 'متقدم',
        category: 'معالجة اللغات',
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
        thumbnailUrl: 'https://picsum.photos/400/225?random=3',
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
        description: 'تعلم برمجة Python من الصفر مع التركيز على تطبيقات الذكاء الاصطناعي.',
        thumbnailUrl: 'https://picsum.photos/400/225?random=4',
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
        description: 'اكتشف عالم الذكاء الاصطناعي التوليدي وتعلم كيفية استخدام ChatGPT.',
        thumbnailUrl: 'https://picsum.photos/400/225?random=5',
        instructorId: '2',
        instructorName: 'د. سارة أحمد',
        instructorBio: 'باحثة في مجال NLP مع خبرة 8 سنوات',
        level: 'متوسط',
        category: 'الذكاء التوليدي',
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
        description: 'دورة عملية متقدمة لبناء وتدريب نماذج الذكاء الاصطناعي.',
        thumbnailUrl: 'https://picsum.photos/400/225?random=6',
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
        description: 'ابدأ رحلتك في علم البيانات مع هذه الدورة المجانية الشاملة.',
        thumbnailUrl: 'https://picsum.photos/400/225?random=7',
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
        description: 'تعلم كيفية تطبيق الذكاء الاصطناعي في بيئة الأعمال.',
        thumbnailUrl: 'https://picsum.photos/400/225?random=8',
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