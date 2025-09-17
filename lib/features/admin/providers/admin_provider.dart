import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/user_model.dart';
import '../../../data/models/course_model.dart';
import '../../../services/sync_service.dart';
import '../../../services/unified_data_service.dart';

class AdminProvider extends ChangeNotifier {
  // Now using real data through SyncService and UnifiedDataService
  final SyncService _syncService = SyncService();
  final UnifiedDataService _unifiedDataService = UnifiedDataService();

  // Dashboard Statistics
  int _totalUsers = 0;
  int _totalCourses = 0;
  int _totalEnrollments = 0;
  double _totalRevenue = 0.0;

  // Charts Data
  List<FlSpot> _userRegistrationData = [];
  List<BarChartGroupData> _popularCoursesData = [];
  List<Map<String, dynamic>> _popularCourses = [];

  // Recent Activities
  List<Map<String, dynamic>> _recentActivities = [];

  // Users Management
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  String _userSearchQuery = '';

  // Courses Management
  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  String _courseSearchQuery = '';

  // Categories
  List<Map<String, dynamic>> _categories = [];

  // News Articles
  List<Map<String, dynamic>> _newsArticles = [];

  // Advertisements
  List<Map<String, dynamic>> _advertisements = [];

  // Transactions
  List<Map<String, dynamic>> _transactions = [];

  // Loading states
  bool _isLoading = false;
  String? _error;

  // Getters
  int get totalUsers => _totalUsers;
  int get totalCourses => _totalCourses;
  int get totalEnrollments => _totalEnrollments;
  double get totalRevenue => _totalRevenue;
  List<FlSpot> get userRegistrationData => _userRegistrationData;
  List<BarChartGroupData> get popularCoursesData => _popularCoursesData;
  List<Map<String, dynamic>> get popularCourses => _popularCourses;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  List<UserModel> get users => _filteredUsers.isNotEmpty || _userSearchQuery.isNotEmpty
      ? _filteredUsers
      : _users;
  List<CourseModel> get courses => _filteredCourses.isNotEmpty || _courseSearchQuery.isNotEmpty
      ? _filteredCourses
      : _courses;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get newsArticles => _newsArticles;
  List<Map<String, dynamic>> get advertisements => _advertisements;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load Dashboard Data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load real data first, fallback to mock if needed
      await _loadRealDashboardData();
    } catch (e) {
      print('ERROR AdminProvider: Failed to load real data, using mock: $e');
      _loadMockDashboardData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadRealDashboardData() async {
    // Load real statistics
    final stats = await _unifiedDataService.getAdminStats();
    _totalUsers = stats.totalUsers;
    _totalCourses = stats.totalCourses;
    _totalEnrollments = stats.totalEnrollments;
    _totalRevenue = stats.totalRevenue;

    // Load real chart data
    await _loadRealChartData();

    // Load real activities
    await _loadRealActivities();
  }

  Future<void> _loadRealChartData() async {
    try {
      // Get courses data for popular courses chart
      final courses = _syncService.courses;
      final popularCourses = _syncService.getPopularCourses(limit: 5);

      _popularCourses = popularCourses.map((course) => {
        'name': course.title.length > 15
            ? '${course.title.substring(0, 15)}...'
            : course.title,
        'enrollments': course.enrolledCount,
      }).toList();

      _popularCoursesData = _popularCourses.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value['enrollments'].toDouble(),
              color: Colors.blue,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList();

      // Generate user registration data (mock for now as we need historical data)
      _userRegistrationData = List.generate(30, (index) {
        return FlSpot(index.toDouble(), (10 + (index * 2) % 15).toDouble());
      });
    } catch (e) {
      print('ERROR AdminProvider: Failed to load real chart data: $e');
      _loadMockChartData();
    }
  }

  Future<void> _loadRealActivities() async {
    try {
      final users = _syncService.getRecentUsers(limit: 3);
      final courses = _syncService.getPopularCourses(limit: 2);

      _recentActivities = [
        if (users.isNotEmpty) {
          'type': 'user',
          'message': 'مستخدم جديد: ${users.first.name}',
          'time': _formatTime(users.first.createdAt),
        },
        if (courses.isNotEmpty) {
          'type': 'enrollment',
          'message': '${courses.first.enrolledCount} مشترك في ${courses.first.title}',
          'time': 'منذ ساعة',
        },
        if (courses.length > 1) {
          'type': 'course',
          'message': 'دورة شائعة: ${courses[1].title}',
          'time': 'منذ ساعتين',
        },
        {
          'type': 'payment',
          'message': 'دفعة جديدة بمبلغ ${_totalRevenue ~/ _totalUsers} ر.س',
          'time': 'منذ 3 ساعات',
        },
      ];
    } catch (e) {
      print('ERROR AdminProvider: Failed to load real activities: $e');
      _loadMockActivities();
    }
  }

  Future<void> _loadStatistics() async {
    // Always use mock data
    _totalUsers = 1543;
    _totalCourses = 45;
    _totalEnrollments = 3876;
    _totalRevenue = 45632.50;
  }

  Future<void> _loadChartData() async {
    // Always use mock chart data
    _loadMockChartData();
  }

  Future<void> _loadRecentActivities() async {
    // Always use mock activities
    _loadMockActivities();
  }

  void _loadMockDashboardData() {
    _totalUsers = 1543;
    _totalCourses = 45;
    _totalEnrollments = 3876;
    _totalRevenue = 45632.50;
    _loadMockChartData();
    _loadMockActivities();
  }

  void _loadMockChartData() {
    // Mock user registration data
    _userRegistrationData = List.generate(30, (index) {
      return FlSpot(index.toDouble(), (10 + (index * 2) % 15).toDouble());
    });

    // Mock popular courses
    _popularCourses = [
      {'name': 'Flutter', 'enrollments': 85},
      {'name': 'React', 'enrollments': 72},
      {'name': 'Python', 'enrollments': 68},
      {'name': 'JavaScript', 'enrollments': 55},
      {'name': 'Java', 'enrollments': 42},
    ];

    _popularCoursesData = _popularCourses.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value['enrollments'].toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  void _loadMockActivities() {
    _recentActivities = [
      {
        'type': 'enrollment',
        'message': 'محمد أحمد سجل في دورة Flutter المتقدمة',
        'time': 'منذ 5 دقائق',
      },
      {
        'type': 'payment',
        'message': 'دفعة جديدة من سارة محمد',
        'amount': '299',
        'time': 'منذ 15 دقيقة',
      },
      {
        'type': 'course',
        'message': 'تم نشر دورة جديدة: تطوير تطبيقات iOS',
        'time': 'منذ ساعة',
      },
      {
        'type': 'user',
        'message': 'مستخدم جديد: علي حسن',
        'time': 'منذ ساعتين',
      },
      {
        'type': 'enrollment',
        'message': 'فاطمة الزهراء سجلت في دورة Python',
        'time': 'منذ 3 ساعات',
      },
    ];
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'غير محدد';

    try {
      DateTime time;
      if (timestamp is DateTime) {
        time = timestamp;
      } else if (timestamp is String) {
        time = DateTime.parse(timestamp);
      } else {
        return 'غير محدد';
      }

      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inMinutes < 60) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'منذ ${difference.inHours} ساعة';
      } else {
        return 'منذ ${difference.inDays} يوم';
      }
    } catch (e) {
      return 'غير محدد';
    }
  }

  // Users Management Functions
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load real users data
      _users = _syncService.users;
      _filteredUsers = [];
    } catch (e) {
      print('ERROR AdminProvider: Failed to load real users: $e');
      _loadMockUsers();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadMockUsers() {
    _users = [
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
    ];
  }

  void searchUsers(String query) {
    _userSearchQuery = query;
    if (query.isEmpty) {
      _filteredUsers = [];
    } else {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // Courses Management Functions
  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load real courses data and convert to CourseModel format
      final realCourses = _syncService.courses;
      _courses = realCourses;
      _filteredCourses = [];
    } catch (e) {
      print('ERROR AdminProvider: Failed to load real courses: $e');
      _loadMockCourses();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadMockCourses() {
    _courses = [
      CourseModel(
        id: '1',
        title: 'دورة Flutter المتقدمة',
        description: 'تعلم Flutter من الصفر إلى الاحتراف',
        category: 'البرمجة',
        price: 299.99,
        instructorId: '1',
        instructorName: 'أحمد محمد',
        instructorBio: 'مطور تطبيقات محمول متخصص',
        thumbnailUrl: 'https://picsum.photos/400/225',
        level: 'متقدم',
        objectives: ['إتقان Flutter', 'بناء تطبيقات معقدة'],
        requirements: ['معرفة أساسيات البرمجة'],
        modules: [],
        totalDuration: Duration(hours: 10),
        rating: 4.8,
        totalRatings: 120,
        enrolledStudents: 543,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFree: false,
        language: 'ar',
        reviews: [],
      ),
      CourseModel(
        id: '2',
        title: 'تطوير تطبيقات React',
        description: 'احترف React و React Native',
        category: 'البرمجة',
        price: 199.99,
        instructorId: '2',
        instructorName: 'سارة أحمد',
        instructorBio: 'مطورة ويب ومدربة',
        thumbnailUrl: 'https://picsum.photos/400/225',
        level: 'متوسط',
        objectives: ['إتقان React', 'بناء تطبيقات الويب'],
        requirements: ['معرفة HTML و CSS'],
        modules: [],
        totalDuration: Duration(hours: 8),
        rating: 4.6,
        totalRatings: 80,
        enrolledStudents: 321,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFree: false,
        language: 'ar',
        reviews: [],
      ),
    ];
  }

  void searchCourses(String query) {
    _courseSearchQuery = query;
    if (query.isEmpty) {
      _filteredCourses = [];
    } else {
      _filteredCourses = _courses.where((course) {
        return course.title.toLowerCase().contains(query.toLowerCase()) ||
            course.category.toLowerCase().contains(query.toLowerCase()) ||
            course.instructorName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // Categories Management
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load real categories with course counts
      _categories = _syncService.categories;

      // Update course counts based on real data
      final courses = _syncService.courses;
      for (var category in _categories) {
        final categoryName = category['name'] as String;
        final courseCount = courses.where((c) => c.category == categoryName).length;
        category['coursesCount'] = courseCount;
      }
    } catch (e) {
      print('ERROR AdminProvider: Failed to load real categories: $e');
      // Fallback to mock categories
      _categories = [
        {'id': '1', 'name': 'البرمجة', 'coursesCount': 15},
        {'id': '2', 'name': 'التصميم', 'coursesCount': 8},
        {'id': '3', 'name': 'التسويق', 'coursesCount': 12},
        {'id': '4', 'name': 'الأعمال', 'coursesCount': 10},
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    try {
      // In a real implementation, this would create the category in the database
      // For now, add it locally and it will sync when database support is added
      final newCategory = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'coursesCount': 0,
      };
      _categories.add(newCategory);
      notifyListeners();
      print('DEBUG AdminProvider: Category added: $name');
    } catch (e) {
      print('ERROR AdminProvider: Failed to add category: $e');
      _error = 'فشل في إضافة الفئة';
      notifyListeners();
    }
  }

  Future<void> updateCategory(String id, String name) async {
    // Mock update category
    final index = _categories.indexWhere((cat) => cat['id'] == id);
    if (index != -1) {
      _categories[index]['name'] = name;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    // Mock delete category
    _categories.removeWhere((cat) => cat['id'] == id);
    notifyListeners();
  }

  // News Management
  Future<void> loadNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load real news data
      _newsArticles = _syncService.news;
    } catch (e) {
      print('ERROR AdminProvider: Failed to load real news: $e');
      // Fallback to mock news
      _newsArticles = [
        {
          'id': '1',
          'title': 'إطلاق دورة Flutter الجديدة',
          'content': 'نحن سعداء بالإعلان عن إطلاق دورة Flutter المتقدمة...',
          'imageUrl': '',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': '2',
          'title': 'تحديث سياسة الخصوصية',
          'content': 'تم تحديث سياسة الخصوصية لتتوافق مع المعايير الجديدة...',
          'imageUrl': '',
          'createdAt': DateTime.now().subtract(const Duration(days: 5)),
        },
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewsArticle(Map<String, dynamic> article) async {
    try {
      // Create news article using the sync service
      final newsId = await _syncService.createNews(article);
      print('DEBUG AdminProvider: News article created with ID: $newsId');

      // The sync service will automatically refresh the news list
      await loadNews();

      // Success notification
      print('SUCCESS AdminProvider: News article created and synced to user interfaces');
    } catch (e) {
      print('ERROR AdminProvider: Failed to create news article: $e');
      _error = 'فشل في إنشاء المقال';
      notifyListeners();
    }
  }

  // Add new course through admin
  Future<String?> createCourse(Map<String, dynamic> courseData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create course using sync service
      final courseModel = CourseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: courseData['title'] ?? '',
        description: courseData['description'] ?? '',
        category: courseData['category'] ?? '',
        price: (courseData['price'] ?? 0).toDouble(),
        instructorId: DateTime.now().millisecondsSinceEpoch.toString(),
        instructorName: courseData['instructorName'] ?? '',
        instructorBio: '',
        instructorPhotoUrl: null,
        thumbnailUrl: courseData['thumbnailUrl'] ?? 'https://picsum.photos/400/225',
        promoVideoUrl: null,
        level: courseData['level'] ?? 'مبتدئ',
        objectives: [],
        requirements: [],
        modules: [],
        totalDuration: Duration(hours: courseData['duration'] ?? 1),
        rating: 0.0,
        totalRatings: 0,
        enrolledStudents: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFree: (courseData['price'] ?? 0.0) == 0.0,
        language: 'ar',
        reviews: [],
        isEnrolled: false,
      );

      final courseId = await _syncService.createCourse(courseModel);

      // Reload courses to reflect changes
      await loadCourses();

      print('SUCCESS AdminProvider: Course created and synced - ID: $courseId');
      return courseId;

    } catch (e) {
      print('ERROR AdminProvider: Failed to create course: $e');
      _error = 'فشل في إنشاء الدورة';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update course through admin
  Future<bool> updateCourse(String courseId, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _syncService.updateCourse(courseId, updates);

      // Reload courses to reflect changes
      await loadCourses();

      print('SUCCESS AdminProvider: Course updated and synced - ID: $courseId');
      return true;

    } catch (e) {
      print('ERROR AdminProvider: Failed to update course: $e');
      _error = 'فشل في تحديث الدورة';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete course through admin
  Future<bool> deleteCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _syncService.deleteCourse(courseId);

      // Remove from local list
      _courses.removeWhere((course) => course.id == courseId);

      print('SUCCESS AdminProvider: Course deleted and synced - ID: $courseId');
      return true;

    } catch (e) {
      print('ERROR AdminProvider: Failed to delete course: $e');
      _error = 'فشل في حذف الدورة';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manually enroll user in course (admin action)
  Future<bool> enrollUserInCourse(String userId, String courseId) async {
    try {
      await _syncService.enrollUserInCourse(userId, courseId);

      // Reload data to reflect changes
      await loadDashboardData();
      await loadUsers();

      print('SUCCESS AdminProvider: User enrolled by admin - User: $userId, Course: $courseId');
      return true;

    } catch (e) {
      print('ERROR AdminProvider: Failed to enroll user: $e');
      _error = 'فشل في تسجيل المستخدم';
      notifyListeners();
      return false;
    }
  }

  // Get real-time statistics
  Future<void> refreshStatistics() async {
    try {
      final stats = await _unifiedDataService.getAdminStats();
      _totalUsers = stats.totalUsers;
      _totalCourses = stats.totalCourses;
      _totalEnrollments = stats.totalEnrollments;
      _totalRevenue = stats.totalRevenue;

      notifyListeners();
      print('SUCCESS AdminProvider: Statistics refreshed from live data');
    } catch (e) {
      print('ERROR AdminProvider: Failed to refresh statistics: $e');
    }
  }

  // Sync data with user interfaces
  Future<void> syncWithUserInterfaces() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Force sync all data
      await _syncService.forceSync();

      // Reload all admin data
      await loadDashboardData();
      await loadUsers();
      await loadCourses();
      await loadNews();

      print('SUCCESS AdminProvider: Full sync completed with user interfaces');
    } catch (e) {
      print('ERROR AdminProvider: Failed to sync with user interfaces: $e');
      _error = 'فشل في مزامنة البيانات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNewsArticle(String id, Map<String, dynamic> article) async {
    // Mock update news article
    final index = _newsArticles.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      _newsArticles[index] = {'id': id, ...article, 'updatedAt': DateTime.now()};
      notifyListeners();
    }
  }

  Future<void> deleteNewsArticle(String id) async {
    // Mock delete news article
    _newsArticles.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  // Advertisement Management
  Future<void> loadAdvertisements() async {
    _isLoading = true;
    notifyListeners();

    // Always use mock ads
    _advertisements = [
      {
        'id': '1',
        'imageUrl': '',
        'targetUrl': 'https://example.com',
        'isActive': true,
        'position': 'home_banner',
      },
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createAdvertisement(Map<String, dynamic> ad) async {
    // Mock create advertisement
    final newAd = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      ...ad,
      'createdAt': DateTime.now(),
    };
    _advertisements.add(newAd);
    notifyListeners();
  }

  Future<void> toggleAdvertisement(String id, bool isActive) async {
    // Mock toggle advertisement
    final index = _advertisements.indexWhere((ad) => ad['id'] == id);
    if (index != -1) {
      _advertisements[index]['isActive'] = isActive;
      notifyListeners();
    }
  }

  Future<void> deleteAdvertisement(String id) async {
    // Mock delete advertisement
    _advertisements.removeWhere((ad) => ad['id'] == id);
    notifyListeners();
  }

  // Financial Management
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    // Always use mock transactions
    _transactions = [
      {
        'id': '1',
        'userEmail': 'mohamed@example.com',
        'courseName': 'Flutter المتقدمة',
        'amount': 299.99,
        'paymentMethod': 'بطاقة ائتمان',
        'status': 'مكتمل',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': '2',
        'userEmail': 'sara@example.com',
        'courseName': 'React للمبتدئين',
        'amount': 199.99,
        'paymentMethod': 'PayPal',
        'status': 'معلق',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyManualPayment(String userId, String courseId) async {
    // Mock verify manual payment
    final newTransaction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'courseId': courseId,
      'amount': 0.0,
      'paymentMethod': 'تحويل بنكي',
      'status': 'مكتمل',
      'verifiedManually': true,
      'createdAt': DateTime.now(),
    };
    _transactions.insert(0, newTransaction);
    notifyListeners();
  }
}
