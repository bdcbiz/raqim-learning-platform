import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/models/course_model.dart';

class CacheService {
  static const String _userKey = 'cached_user';
  static const String _coursesKey = 'cached_courses';
  static const String _enrolledCoursesKey = 'cached_enrolled_courses';
  static const String _progressKey = 'cached_progress';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _cacheExpiryKey = 'cache_expiry_';
  
  static const Duration defaultCacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(minutes: 30);
  
  static late SharedPreferences _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // User Data Caching
  static Future<void> cacheUserData(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _prefs.setString(_userKey, userJson);
      await _setCacheExpiry(_userKey, defaultCacheDuration);
    } catch (e) {
      print('Error caching user data: $e');
    }
  }
  
  static UserModel? getCachedUser() {
    try {
      if (!_isCacheValid(_userKey)) {
        clearUserCache();
        return null;
      }
      
      final userJson = _prefs.getString(_userKey);
      if (userJson != null) {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Error getting cached user: $e');
    }
    return null;
  }
  
  static Future<void> clearUserCache() async {
    await _prefs.remove(_userKey);
    await _prefs.remove('$_cacheExpiryKey$_userKey');
  }
  
  // Courses Data Caching
  static Future<void> cacheCourses(List<CourseModel> courses) async {
    try {
      final coursesJson = jsonEncode(
        courses.map((course) => course.toJson()).toList()
      );
      await _prefs.setString(_coursesKey, coursesJson);
      await _setCacheExpiry(_coursesKey, shortCacheDuration);
    } catch (e) {
      print('Error caching courses: $e');
    }
  }
  
  static List<CourseModel>? getCachedCourses() {
    try {
      if (!_isCacheValid(_coursesKey)) {
        clearCoursesCache();
        return null;
      }
      
      final coursesJson = _prefs.getString(_coursesKey);
      if (coursesJson != null) {
        final List<dynamic> coursesData = jsonDecode(coursesJson);
        return coursesData
            .map((json) => CourseModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error getting cached courses: $e');
    }
    return null;
  }
  
  static Future<void> clearCoursesCache() async {
    await _prefs.remove(_coursesKey);
    await _prefs.remove('$_cacheExpiryKey$_coursesKey');
  }
  
  // Enrolled Courses Caching
  static Future<void> cacheEnrolledCourses(List<String> courseIds) async {
    try {
      await _prefs.setStringList(_enrolledCoursesKey, courseIds);
      await _setCacheExpiry(_enrolledCoursesKey, shortCacheDuration);
    } catch (e) {
      print('Error caching enrolled courses: $e');
    }
  }
  
  static List<String>? getCachedEnrolledCourses() {
    try {
      if (!_isCacheValid(_enrolledCoursesKey)) {
        clearEnrolledCoursesCache();
        return null;
      }
      
      return _prefs.getStringList(_enrolledCoursesKey);
    } catch (e) {
      print('Error getting cached enrolled courses: $e');
    }
    return null;
  }
  
  static Future<void> clearEnrolledCoursesCache() async {
    await _prefs.remove(_enrolledCoursesKey);
    await _prefs.remove('$_cacheExpiryKey$_enrolledCoursesKey');
  }
  
  // Progress Data Caching
  static Future<void> cacheProgress(Map<String, dynamic> progress) async {
    try {
      final progressJson = jsonEncode(progress);
      await _prefs.setString(_progressKey, progressJson);
      await _setCacheExpiry(_progressKey, shortCacheDuration);
    } catch (e) {
      print('Error caching progress: $e');
    }
  }
  
  static Map<String, dynamic>? getCachedProgress() {
    try {
      if (!_isCacheValid(_progressKey)) {
        clearProgressCache();
        return null;
      }
      
      final progressJson = _prefs.getString(_progressKey);
      if (progressJson != null) {
        return jsonDecode(progressJson);
      }
    } catch (e) {
      print('Error getting cached progress: $e');
    }
    return null;
  }
  
  static Future<void> clearProgressCache() async {
    await _prefs.remove(_progressKey);
    await _prefs.remove('$_cacheExpiryKey$_progressKey');
  }
  
  // Last Sync Timestamp
  static Future<void> updateLastSync() async {
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  static DateTime? getLastSync() {
    final timestamp = _prefs.getInt(_lastSyncKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  
  static bool shouldRefreshCache() {
    final lastSync = getLastSync();
    if (lastSync == null) return true;
    
    final difference = DateTime.now().difference(lastSync);
    return difference.inMinutes > 30;
  }
  
  // Cache Expiry Management
  static Future<void> _setCacheExpiry(String key, Duration duration) async {
    final expiryTime = DateTime.now().add(duration).millisecondsSinceEpoch;
    await _prefs.setInt('$_cacheExpiryKey$key', expiryTime);
  }
  
  static bool _isCacheValid(String key) {
    final expiryTime = _prefs.getInt('$_cacheExpiryKey$key');
    if (expiryTime == null) return false;
    
    return DateTime.now().millisecondsSinceEpoch < expiryTime;
  }
  
  // Clear All Cache
  static Future<void> clearAllCache() async {
    final keys = _prefs.getKeys();
    for (String key in keys) {
      if (key != 'auth_token' && 
          key != 'theme_mode' && 
          key != 'locale' &&
          !key.contains('settings')) {
        await _prefs.remove(key);
      }
    }
  }
  
  // Offline Mode Support
  static Future<void> saveOfflineData(String key, dynamic data) async {
    try {
      final jsonData = jsonEncode(data);
      await _prefs.setString('offline_$key', jsonData);
    } catch (e) {
      print('Error saving offline data: $e');
    }
  }
  
  static dynamic getOfflineData(String key) {
    try {
      final jsonData = _prefs.getString('offline_$key');
      if (jsonData != null) {
        return jsonDecode(jsonData);
      }
    } catch (e) {
      print('Error getting offline data: $e');
    }
    return null;
  }
  
  static Future<void> clearOfflineData(String key) async {
    await _prefs.remove('offline_$key');
  }
  
  // Search History
  static Future<void> saveSearchHistory(List<String> searches) async {
    await _prefs.setStringList('search_history', searches);
  }
  
  static List<String> getSearchHistory() {
    return _prefs.getStringList('search_history') ?? [];
  }
  
  // Recently Viewed Courses
  static Future<void> saveRecentlyViewed(List<String> courseIds) async {
    // Keep only last 10 viewed courses
    if (courseIds.length > 10) {
      courseIds = courseIds.sublist(0, 10);
    }
    await _prefs.setStringList('recently_viewed', courseIds);
  }
  
  static List<String> getRecentlyViewed() {
    return _prefs.getStringList('recently_viewed') ?? [];
  }
  
  static Future<void> addToRecentlyViewed(String courseId) async {
    List<String> recentlyViewed = getRecentlyViewed();
    recentlyViewed.remove(courseId); // Remove if exists
    recentlyViewed.insert(0, courseId); // Add to beginning
    await saveRecentlyViewed(recentlyViewed);
  }
}