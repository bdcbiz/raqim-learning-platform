import '../models/user_model.dart';
import '../data/models/course_model.dart';
import 'mock_data_service.dart';
import 'api_service.dart';

class UnifiedDataService {
  static final UnifiedDataService _instance = UnifiedDataService._internal();
  factory UnifiedDataService() => _instance;
  UnifiedDataService._internal();

  final MockDataService _mockDataService = MockDataService();

  // Collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String enrollmentsCollection = 'enrollments';
  static const String newsCollection = 'news';
  static const String categoriesCollection = 'categories';
  static const String transactionsCollection = 'transactions';
  static const String statisticsCollection = 'statistics';
  static const String postsCollection = 'community_posts';
  static const String commentsCollection = 'comments';

  // Mock data storage
  final List<UserModel> _mockUsers = [];
  final List<Map<String, dynamic>> _mockPosts = [];
  final List<Map<String, dynamic>> _mockComments = [];
  final List<Map<String, dynamic>> _mockNews = [];
  final List<Map<String, dynamic>> _mockCategories = [];

  // ======================== USERS MANAGEMENT ========================

  Future<List<UserModel>> getAllUsers() async {
    try {
      // Temporarily returning mock data until Firebase is re-enabled
      print('DEBUG UnifiedDataService: Using mock users data (Firebase temporarily disabled)');
      return _getMockUsers();
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get users: $e');
      return _getMockUsers();
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final users = _getMockUsers();
      return users.firstWhere((u) => u.id == userId, orElse: () => users.first);
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get user: $e');
      return null;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Mock implementation - just log the update
      updates['updatedAt'] = DateTime.now();
      print('DEBUG UnifiedDataService: Mock update user $userId with $updates');
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to update user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  // ======================== COURSES MANAGEMENT ========================

  Future<List<CourseModel>> getAllCourses() async {
    try {
      print('DEBUG UnifiedDataService: Fetching courses from Laravel API');
      final response = await ApiService.getCourses();

      if (response['success'] == true) {
        final coursesData = response['data'] as List;
        return coursesData.map((courseData) => CourseModel.fromJson(courseData)).toList();
      } else {
        throw Exception('Failed to get courses from API');
      }
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get courses: $e');
      print('DEBUG UnifiedDataService: Falling back to mock data');
      return _getMockCourses();
    }
  }

  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      print('DEBUG UnifiedDataService: Fetching course $courseId from Laravel API');
      final response = await ApiService.getCourse(int.parse(courseId));

      if (response['success'] == true) {
        return CourseModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to get course from API');
      }
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get course: $e');
      print('DEBUG UnifiedDataService: Falling back to mock data');
      final courses = _getMockCourses();
      try {
        return courses.firstWhere((c) => c.id == courseId);
      } catch (e) {
        return courses.isNotEmpty ? courses.first : null;
      }
    }
  }

  Future<String> addCourse(Map<String, dynamic> courseData) async {
    try {
      // Mock implementation
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      courseData['id'] = id;
      courseData['createdAt'] = DateTime.now();
      courseData['updatedAt'] = DateTime.now();
      print('DEBUG UnifiedDataService: Mock add course with id: $id');
      return id;
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to add course: $e');
      throw Exception('Failed to add course: $e');
    }
  }

  Future<void> updateCourse(String courseId, Map<String, dynamic> updates) async {
    try {
      // Mock implementation
      updates['updatedAt'] = DateTime.now();
      print('DEBUG UnifiedDataService: Mock update course $courseId');
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to update course: $e');
      throw Exception('Failed to update course: $e');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      // Mock implementation
      print('DEBUG UnifiedDataService: Mock delete course $courseId');
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to delete course: $e');
      throw Exception('Failed to delete course: $e');
    }
  }

  // ======================== ENROLLMENT MANAGEMENT ========================

  Future<void> enrollUserInCourse(String userId, String courseId, Map<String, dynamic> paymentData) async {
    try {
      // Mock implementation
      print('DEBUG UnifiedDataService: Mock enroll user $userId in course $courseId');
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to enroll user: $e');
      throw Exception('Failed to enroll user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserEnrollments(String userId) async {
    try {
      // Mock implementation
      return [
        {
          'courseId': '1',
          'userId': userId,
          'enrolledAt': DateTime.now().subtract(Duration(days: 10)),
          'progress': 0.45,
          'lastAccessedAt': DateTime.now().subtract(Duration(days: 2)),
        },
        {
          'courseId': '2',
          'userId': userId,
          'enrolledAt': DateTime.now().subtract(Duration(days: 30)),
          'progress': 0.75,
          'lastAccessedAt': DateTime.now().subtract(Duration(hours: 5)),
        },
      ];
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get enrollments: $e');
      return [];
    }
  }

  // ======================== STATISTICS & ANALYTICS ========================

  Future<int> getTotalUsers() async {
    try {
      return _getMockUsers().length;
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get total users: $e');
      return 1234; // Mock count
    }
  }

  Future<int> getTotalCourses() async {
    try {
      return _getMockCourses().length;
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get total courses: $e');
      return 28; // Updated mock count to match MockDataService
    }
  }

  Future<int> getTotalEnrollments() async {
    try {
      return 456; // Mock count
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get total enrollments: $e');
      return 456;
    }
  }

  Future<double> getTotalRevenue(DateTime? startDate, DateTime? endDate) async {
    try {
      // Mock revenue calculation
      return 12345.67;
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get revenue: $e');
      return 0.0;
    }
  }


  // ======================== CONTENT MANAGEMENT ========================

  Future<List<Map<String, dynamic>>> getCourseReviews(String courseId) async {
    try {
      // Mock reviews
      return [
        {
          'id': '1',
          'userId': 'user1',
          'userName': 'محمد أحمد',
          'rating': 5,
          'comment': 'دورة ممتازة، شرح واضح ومفصل',
          'createdAt': DateTime.now().subtract(Duration(days: 5)),
        },
        {
          'id': '2',
          'userId': 'user2',
          'userName': 'سارة محمد',
          'rating': 4,
          'comment': 'محتوى جيد لكن يحتاج المزيد من الأمثلة',
          'createdAt': DateTime.now().subtract(Duration(days: 10)),
        },
      ];
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get reviews: $e');
      return [];
    }
  }

  // ======================== NEWS MANAGEMENT ========================

  Future<List<Map<String, dynamic>>> getAllNews() async {
    try {
      print('DEBUG UnifiedDataService: Fetching news from Laravel API');
      final response = await ApiService.getNews();

      if (response['success'] == true) {
        final newsData = response['data'] as List;
        return newsData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get news from API');
      }
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get news: $e');
      print('DEBUG UnifiedDataService: Falling back to mock data');
      if (_mockNews.isEmpty) {
        _mockNews.addAll(_getMockNews());
      }
      return _mockNews;
    }
  }

  Future<String> addNews(Map<String, dynamic> newsData) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      newsData['id'] = id;
      newsData['createdAt'] = DateTime.now();
      newsData['updatedAt'] = DateTime.now();
      _mockNews.add(newsData);
      print('DEBUG UnifiedDataService: Mock add news with id: $id');
      return id;
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to add news: $e');
      throw Exception('Failed to add news: $e');
    }
  }

  // ======================== CATEGORIES MANAGEMENT ========================

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      print('DEBUG UnifiedDataService: Fetching categories from Laravel API');
      final response = await ApiService.getCategories();

      if (response['success'] == true) {
        final categoriesData = response['categories'] as List;
        return categoriesData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get categories from API');
      }
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get categories: $e');
      print('DEBUG UnifiedDataService: Falling back to mock data');
      if (_mockCategories.isEmpty) {
        _mockCategories.addAll(_getMockCategories());
      }
      return _mockCategories;
    }
  }

  // ======================== COMMUNITY POSTS MANAGEMENT ========================

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    try {
      if (_mockPosts.isEmpty) {
        _mockPosts.addAll(_getMockPosts());
      }
      return _mockPosts;
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get posts: $e');
      return _getMockPosts();
    }
  }

  Future<String> addPost(Map<String, dynamic> postData) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      postData['id'] = id;
      postData['createdAt'] = DateTime.now();
      postData['updatedAt'] = DateTime.now();
      postData['likes'] = 0;
      postData['commentsCount'] = 0;
      _mockPosts.add(postData);
      print('DEBUG UnifiedDataService: Mock add post with id: $id');
      return id;
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to add post: $e');
      throw Exception('Failed to add post: $e');
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final postIndex = _mockPosts.indexWhere((p) => p['id'] == postId);
      if (postIndex != -1) {
        final post = _mockPosts[postIndex];
        final likedBy = post['likedBy'] as List<String>? ?? [];

        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
          post['likes'] = (post['likes'] as int? ?? 1) - 1;
        } else {
          likedBy.add(userId);
          post['likes'] = (post['likes'] as int? ?? 0) + 1;
        }

        post['likedBy'] = likedBy;
        post['updatedAt'] = DateTime.now();
        print('DEBUG UnifiedDataService: Mock toggle like on post $postId by user $userId');
      }
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to like post: $e');
      throw Exception('Failed to like post: $e');
    }
  }

  Future<String> addComment(String postId, Map<String, dynamic> commentData) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      commentData['id'] = id;
      commentData['postId'] = postId;
      commentData['createdAt'] = DateTime.now();
      _mockComments.add(commentData);

      // Update post comments count
      final postIndex = _mockPosts.indexWhere((p) => p['id'] == postId);
      if (postIndex != -1) {
        _mockPosts[postIndex]['commentsCount'] = (_mockPosts[postIndex]['commentsCount'] as int? ?? 0) + 1;
        _mockPosts[postIndex]['updatedAt'] = DateTime.now();
      }

      print('DEBUG UnifiedDataService: Mock add comment with id: $id to post $postId');
      return id;
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to add comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    try {
      return _mockComments.where((c) => c['postId'] == postId).toList();
    } catch (e) {
      print('ERROR UnifiedDataService: Failed to get comments: $e');
      return [];
    }
  }

  // ======================== SYNC SERVICE METHODS ========================

  Future<List<UserModel>> getUsers() async {
    return await getAllUsers();
  }

  Future<List<CourseModel>> getCourses() async {
    return await getAllCourses();
  }

  Future<List<Map<String, dynamic>>> getNews() async {
    return await getAllNews();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    return await getAllCategories();
  }

  // ======================== REAL-TIME LISTENERS ========================

  Stream<List<UserModel>> getUsersStream() {
    // Mock stream that emits data periodically
    return Stream.periodic(Duration(seconds: 30), (_) => _getMockUsers())
        .asyncMap((users) async => users);
  }

  Stream<List<CourseModel>> getCoursesStream() {
    // Mock stream that emits data periodically
    return Stream.periodic(Duration(seconds: 30), (_) => _getMockCourses())
        .asyncMap((courses) async => courses);
  }


  // ======================== MOCK DATA FALLBACKS ========================

  List<UserModel> _getMockUsers() {
    if (_mockUsers.isEmpty) {
      _mockUsers.addAll([
        UserModel(
          id: '1',
          name: 'محمد أحمد',
          email: 'mohamed@example.com',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          emailVerified: true,
        ),
        UserModel(
          id: '2',
          name: 'سارة محمد',
          email: 'sara@example.com',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          emailVerified: true,
        ),
        UserModel(
          id: '3',
          name: 'علي حسن',
          email: 'ali@example.com',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          emailVerified: false,
        ),
      ]);
    }
    return _mockUsers;
  }

  List<CourseModel> _getMockCourses() {
    return _mockDataService.getAllCourses();
  }

  List<Map<String, dynamic>> _getMockNews() {
    return [
      {
        'id': '1',
        'title': 'إطلاق دورات جديدة في الذكاء الاصطناعي',
        'content': 'نحن سعداء بالإعلان عن إطلاق سلسلة جديدة من الدورات...',
        'imageUrl': 'https://picsum.photos/400/225',
        'author': 'فريق المنصة',
        'createdAt': DateTime.now().subtract(Duration(days: 2)),
        'views': 234,
      },
      {
        'id': '2',
        'title': 'تحديث منصة التعلم بمميزات جديدة',
        'content': 'تم إضافة العديد من المميزات الجديدة لتحسين تجربة التعلم...',
        'imageUrl': 'https://picsum.photos/400/225',
        'author': 'فريق التطوير',
        'createdAt': DateTime.now().subtract(Duration(days: 5)),
        'views': 567,
      },
    ];
  }

  List<Map<String, dynamic>> _getMockCategories() {
    return [
      {'id': '1', 'name': 'البرمجة', 'icon': 'code', 'coursesCount': 15},
      {'id': '2', 'name': 'التصميم', 'icon': 'design_services', 'coursesCount': 8},
      {'id': '3', 'name': 'التسويق', 'icon': 'campaign', 'coursesCount': 12},
      {'id': '4', 'name': 'اللغات', 'icon': 'language', 'coursesCount': 6},
      {'id': '5', 'name': 'الأعمال', 'icon': 'business', 'coursesCount': 10},
    ];
  }

  List<Map<String, dynamic>> _getMockPosts() {
    return [
      {
        'id': '1',
        'title': 'كيف تبدأ رحلتك في تعلم Flutter؟',
        'content': 'Flutter هو إطار عمل رائع لتطوير التطبيقات...',
        'authorId': '1',
        'authorName': 'محمد أحمد',
        'authorAvatar': 'https://picsum.photos/100/100',
        'likes': 45,
        'commentsCount': 12,
        'createdAt': DateTime.now().subtract(Duration(hours: 5)),
        'tags': ['Flutter', 'برمجة', 'تطوير'],
        'likedBy': [],
      },
      {
        'id': '2',
        'title': 'نصائح للنجاح في التعلم عن بعد',
        'content': 'التعلم عن بعد يتطلب الانضباط والتخطيط الجيد...',
        'authorId': '2',
        'authorName': 'سارة محمد',
        'authorAvatar': 'https://picsum.photos/100/100',
        'likes': 32,
        'commentsCount': 8,
        'createdAt': DateTime.now().subtract(Duration(days: 1)),
        'tags': ['تعلم', 'نصائح', 'تطوير شخصي'],
        'likedBy': [],
      },
    ];
  }
}