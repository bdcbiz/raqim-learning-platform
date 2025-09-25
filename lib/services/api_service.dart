import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../data/models/course_model.dart';

class ApiService {
  static String get baseUrl {
    // Use 192.168.1.143 for physical devices, localhost for web
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else {
      // Use computer's local IP address for physical devices
      return 'http://192.168.1.143:8000/api';
    }
  }
  static String? authToken;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
  }


  static Future<void> saveToken(String token) async {
    authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get auth token from storage
  static Future<String?> getAuthToken() async {
    if (authToken != null) return authToken;

    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    return authToken;
  }

  // Get headers with auth token
  static Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle API response
  static Map<String, dynamic> handleResponse(http.Response response) {
    final data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'API Error: ${response.statusCode}');
    }
  }

  // Auth Methods
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: headers,
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    final data = handleResponse(response);

    if (data['token'] != null) {
      await saveToken(data['token']);
    }

    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = handleResponse(response);

    if (data['token'] != null) {
      await saveToken(data['token']);
    }

    return data;
  }

  static Future<Map<String, dynamic>> logout() async {
    final headers = await getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: headers,
    );

    await clearToken();

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
  }) async {
    final headers = await getHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl/user/profile'),
      headers: headers,
      body: json.encode({
        'name': name,
        'phone': phone,
      }),
    );

    return handleResponse(response);
  }

  // Course Methods
  static Future<Map<String, dynamic>> getCourses({
    int? categoryId,
    String? search,
    String? isFree,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
  }) async {
    final headers = await getHeaders(includeAuth: false);

    Map<String, String> queryParams = {
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'page': page.toString(),
    };

    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (isFree != null) {
      queryParams['is_free'] = isFree;
    }

    final uri = Uri.parse('$baseUrl/courses').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getCourse(int id) async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.get(
      Uri.parse('$baseUrl/courses/$id'),
      headers: headers,
    );

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getCategories() async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
    );

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> enrollInCourse(int courseId) async {
    final headers = await getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/courses/$courseId/enroll'),
      headers: headers,
    );

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMyEnrollments({int page = 1}) async {
    final headers = await getHeaders();

    final uri = Uri.parse('$baseUrl/my-enrollments').replace(
      queryParameters: {'page': page.toString()},
    );

    final response = await http.get(uri, headers: headers);

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateCourseProgress({
    required int courseId,
    required double progress,
  }) async {
    final headers = await getHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl/courses/$courseId/progress'),
      headers: headers,
      body: json.encode({'progress': progress}),
    );

    return handleResponse(response);
  }

  // News Methods
  static Future<Map<String, dynamic>> getNews({
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
  }) async {
    final headers = await getHeaders(includeAuth: false);

    Map<String, String> queryParams = {
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'page': page.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('$baseUrl/news').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getNewsItem(int id) async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.get(
      Uri.parse('$baseUrl/news/$id'),
      headers: headers,
    );

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getLatestNews() async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.get(
      Uri.parse('$baseUrl/news/latest'),
      headers: headers,
    );

    return handleResponse(response);
  }

  // Jobs Methods
  static Future<Map<String, dynamic>> getJobs({
    String? search,
    String? type,
    String? location,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
  }) async {
    final headers = await getHeaders(includeAuth: false);

    Map<String, String> queryParams = {
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'page': page.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }

    final uri = Uri.parse('$baseUrl/jobs').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getJob(int id) async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.get(
      Uri.parse('$baseUrl/jobs/$id'),
      headers: headers,
    );

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getLatestJobs() async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.get(
      Uri.parse('$baseUrl/jobs/latest'),
      headers: headers,
    );

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getJobTypes() async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.get(
      Uri.parse('$baseUrl/jobs/types'),
      headers: headers,
    );

    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getJobLocations() async {
    final headers = await getHeaders(includeAuth: false);

    final response = await http.get(
      Uri.parse('$baseUrl/jobs/locations'),
      headers: headers,
    );

    return handleResponse(response);
  }
}