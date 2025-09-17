import 'dart:async';
import 'package:flutter/material.dart';
import 'unified_data_service.dart';
import '../models/user_model.dart';
import '../data/models/course_model.dart';
import '../features/admin/models/admin_stats.dart';

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal() {
    _initializeListeners();
  }

  final UnifiedDataService _unifiedDataService = UnifiedDataService();

  // Cached data
  List<UserModel> _users = [];
  List<CourseModel> _courses = [];
  AdminStats? _adminStats;
  List<Map<String, dynamic>> _news = [];
  List<Map<String, dynamic>> _categories = [];

  // Stream subscriptions
  StreamSubscription<List<UserModel>>? _usersSubscription;
  StreamSubscription<List<CourseModel>>? _coursesSubscription;
  StreamSubscription<AdminStats>? _statsSubscription;

  // Last sync timestamps
  DateTime? _lastUsersSync;
  DateTime? _lastCoursesSync;
  DateTime? _lastStatsSync;

  // Sync status
  bool _isSyncing = false;
  String? _syncError;

  // Getters
  List<UserModel> get users => _users;
  List<CourseModel> get courses => _courses;
  AdminStats? get adminStats => _adminStats;
  List<Map<String, dynamic>> get news => _news;
  List<Map<String, dynamic>> get categories => _categories;
  DateTime? get lastUsersSync => _lastUsersSync;
  DateTime? get lastCoursesSync => _lastCoursesSync;
  DateTime? get lastStatsSync => _lastStatsSync;
  bool get isSyncing => _isSyncing;
  String? get syncError => _syncError;

  void _initializeListeners() {
    // Listen to users changes
    _usersSubscription = _unifiedDataService.getUsersStream().listen(
      (users) {
        _users = users;
        _lastUsersSync = DateTime.now();
        _syncError = null;
        notifyListeners();
        print('DEBUG SyncService: Users synced - ${users.length} users');
      },
      onError: (error) {
        _syncError = 'Failed to sync users: $error';
        notifyListeners();
        print('ERROR SyncService: Users sync failed - $error');
      },
    );

    // Listen to courses changes
    _coursesSubscription = _unifiedDataService.getCoursesStream().listen(
      (courses) {
        _courses = courses;
        _lastCoursesSync = DateTime.now();
        _syncError = null;
        notifyListeners();
        print('DEBUG SyncService: Courses synced - ${courses.length} courses');
      },
      onError: (error) {
        _syncError = 'Failed to sync courses: $error';
        notifyListeners();
        print('ERROR SyncService: Courses sync failed - $error');
      },
    );

    // Listen to admin stats changes (periodic updates)
    _statsSubscription = _unifiedDataService.getAdminStatsStream().listen(
      (stats) {
        _adminStats = stats;
        _lastStatsSync = DateTime.now();
        _syncError = null;
        notifyListeners();
        print('DEBUG SyncService: Admin stats synced');
      },
      onError: (error) {
        _syncError = 'Failed to sync admin stats: $error';
        notifyListeners();
        print('ERROR SyncService: Admin stats sync failed - $error');
      },
    );

    // Initial data load
    _performInitialSync();
  }

  Future<void> _performInitialSync() async {
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      // Load all data concurrently for better performance
      final futures = await Future.wait([
        _syncUsers(),
        _syncCourses(),
        _syncAdminStats(),
        _syncNews(),
        _syncCategories(),
      ]);

      print('DEBUG SyncService: Initial sync completed successfully');
    } catch (e) {
      _syncError = 'Failed to perform initial sync: $e';
      print('ERROR SyncService: Initial sync failed - $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _syncUsers() async {
    try {
      _users = await _unifiedDataService.getAllUsers();
      _lastUsersSync = DateTime.now();
    } catch (e) {
      print('ERROR SyncService: Failed to sync users - $e');
      rethrow;
    }
  }

  Future<void> _syncCourses() async {
    try {
      _courses = await _unifiedDataService.getAllCourses();
      _lastCoursesSync = DateTime.now();
    } catch (e) {
      print('ERROR SyncService: Failed to sync courses - $e');
      rethrow;
    }
  }

  Future<void> _syncAdminStats() async {
    try {
      _adminStats = await _unifiedDataService.getAdminStats();
      _lastStatsSync = DateTime.now();
    } catch (e) {
      print('ERROR SyncService: Failed to sync admin stats - $e');
      rethrow;
    }
  }

  Future<void> _syncNews() async {
    try {
      _news = await _unifiedDataService.getAllNews();
    } catch (e) {
      print('ERROR SyncService: Failed to sync news - $e');
      rethrow;
    }
  }

  Future<void> _syncCategories() async {
    try {
      _categories = await _unifiedDataService.getAllCategories();
    } catch (e) {
      print('ERROR SyncService: Failed to sync categories - $e');
      rethrow;
    }
  }

  // Manual sync methods
  Future<void> forceSync() async {
    await _performInitialSync();
  }

  Future<void> syncUsers() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _syncUsers();
      _syncError = null;
    } catch (e) {
      _syncError = 'Failed to sync users: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncCourses() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _syncCourses();
      _syncError = null;
    } catch (e) {
      _syncError = 'Failed to sync courses: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Data modification methods (these trigger sync automatically)
  Future<String> createCourse(CourseModel course) async {
    try {
      // Convert CourseModel to Map for addCourse method
      final courseData = {
        'title': course.title,
        'description': course.description,
        'thumbnailUrl': course.thumbnailUrl,
        'instructorId': course.instructorId,
        'instructorName': course.instructorName,
        'instructorBio': course.instructorBio,
        'level': course.level,
        'category': course.category,
        'price': course.price,
        'rating': course.rating,
        'totalRatings': course.totalRatings,
        'enrolledStudents': course.enrolledStudents,
        'totalDuration': course.totalDuration.inSeconds,
        'objectives': course.objectives,
        'requirements': course.requirements,
      };
      final courseId = await _unifiedDataService.addCourse(courseData);
      // Real-time listener will automatically update _courses
      return courseId;
    } catch (e) {
      _syncError = 'Failed to create course: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCourse(String courseId, Map<String, dynamic> updates) async {
    try {
      await _unifiedDataService.updateCourse(courseId, updates);
      // Real-time listener will automatically update _courses
    } catch (e) {
      _syncError = 'Failed to update course: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _unifiedDataService.deleteCourse(courseId);
      // Real-time listener will automatically update _courses
    } catch (e) {
      _syncError = 'Failed to delete course: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> enrollUserInCourse(String userId, String courseId) async {
    try {
      await _unifiedDataService.enrollUserInCourse(userId, courseId, {});
      // Trigger stats sync as enrollment count changed
      await _syncAdminStats();
    } catch (e) {
      _syncError = 'Failed to enroll user: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _unifiedDataService.updateUser(userId, updates);
      // Real-time listener will automatically update _users
    } catch (e) {
      _syncError = 'Failed to update user: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<String> createNews(Map<String, dynamic> newsData) async {
    try {
      final newsId = await _unifiedDataService.addNews(newsData);
      // Manually refresh news as it doesn't have real-time listener
      await _syncNews();
      return newsId;
    } catch (e) {
      _syncError = 'Failed to create news: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Search and filter methods
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return _users;

    return _users.where((user) {
      return user.name.toLowerCase().contains(query.toLowerCase()) ||
             user.email.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<CourseModel> searchCourses(String query) {
    if (query.isEmpty) return _courses;

    return _courses.where((course) {
      return course.title.toLowerCase().contains(query.toLowerCase()) ||
             course.description.toLowerCase().contains(query.toLowerCase()) ||
             course.category.toLowerCase().contains(query.toLowerCase()) ||
             course.instructorName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<CourseModel> filterCoursesByCategory(String category) {
    if (category == 'الكل') return _courses;
    return _courses.where((course) => course.category == category).toList();
  }

  List<CourseModel> filterCoursesByLevel(String level) {
    if (level == 'الكل') return _courses;
    return _courses.where((course) => course.level == level).toList();
  }

  // Statistics helpers
  int getTotalUsers() => _users.length;
  int getTotalCourses() => _courses.length;
  double getTotalRevenue() => _adminStats?.totalRevenue ?? 0.0;
  int getTotalEnrollments() => _adminStats?.totalEnrollments ?? 0;

  List<UserModel> getRecentUsers({int limit = 10}) {
    final sortedUsers = List<UserModel>.from(_users);
    sortedUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedUsers.take(limit).toList();
  }

  List<CourseModel> getPopularCourses({int limit = 10}) {
    final sortedCourses = List<CourseModel>.from(_courses);
    sortedCourses.sort((a, b) => b.enrolledCount.compareTo(a.enrolledCount));
    return sortedCourses.take(limit).toList();
  }

  // Check data freshness
  bool isDataStale({Duration maxAge = const Duration(minutes: 10)}) {
    final now = DateTime.now();

    if (_lastUsersSync == null || now.difference(_lastUsersSync!) > maxAge) {
      return true;
    }

    if (_lastCoursesSync == null || now.difference(_lastCoursesSync!) > maxAge) {
      return true;
    }

    if (_lastStatsSync == null || now.difference(_lastStatsSync!) > maxAge) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _coursesSubscription?.cancel();
    _statsSubscription?.cancel();
    super.dispose();
  }
}
