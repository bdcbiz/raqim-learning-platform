import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    // Use 10.0.2.2 for Android emulator, localhost for web
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/v1';
    } else {
      return 'http://localhost:5000/api/v1';
    }
  }
  static String? authToken;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
  }

  static Future<Map<String, String>> get _headers async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    
    return headers;
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

  // Auth Methods
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        await saveToken(data['token']);
        return data;
      } else if (response.statusCode == 400) {
        // Handle duplicate user error
        throw Exception(data['error'] ?? 'Registration failed');
      } else {
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await saveToken(data['token']);
      }
      
      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _headers,
      );
      await clearToken();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Course Methods
  static Future<Map<String, dynamic>> getCourses({
    String? category,
    String? level,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url = '$baseUrl/courses?page=$page&limit=$limit';
      
      if (category != null) url += '&category=$category';
      if (level != null) url += '&level=$level';
      if (search != null) url += '&search=$search';
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get courses: $e');
    }
  }

  static Future<Map<String, dynamic>> getCourse(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses/$courseId'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get course: $e');
    }
  }

  static Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/courses/$courseId/enroll'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to enroll in course: $e');
    }
  }

  static Future<Map<String, dynamic>> getEnrolledCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses/enrolled'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get enrolled courses: $e');
    }
  }

  // Lesson Methods
  static Future<Map<String, dynamic>> getLessons(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/course/$courseId'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get lessons: $e');
    }
  }

  static Future<Map<String, dynamic>> getLesson(String lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$lessonId'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get lesson: $e');
    }
  }

  static Future<Map<String, dynamic>> completeLesson(
    String lessonId, {
    int? score,
    int? timeSpent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lessons/$lessonId/complete'),
        headers: await _headers,
        body: jsonEncode({
          if (score != null) 'score': score,
          if (timeSpent != null) 'timeSpent': timeSpent,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to complete lesson: $e');
    }
  }

  static Future<Map<String, dynamic>> submitQuiz(
    String lessonId,
    List<String> answers,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lessons/$lessonId/quiz/submit'),
        headers: await _headers,
        body: jsonEncode({'answers': answers}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  // Progress Methods
  static Future<Map<String, dynamic>> getCourseProgress(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress/course/$courseId'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get progress: $e');
    }
  }

  static Future<Map<String, dynamic>> getAllProgress() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get all progress: $e');
    }
  }

  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress/statistics'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // Upload Methods
  static Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/avatar'),
      );
      
      request.headers.addAll(await _headers);
      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));
      
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      
      return jsonDecode(responseString);
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  static Future<Map<String, dynamic>> uploadCourseThumbnail(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/thumbnail'),
      );
      
      request.headers.addAll(await _headers);
      request.files.add(await http.MultipartFile.fromPath('thumbnail', filePath));
      
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      
      return jsonDecode(responseString);
    } catch (e) {
      throw Exception('Failed to upload thumbnail: $e');
    }
  }

  static Future<Map<String, dynamic>> uploadVideo(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/video'),
      );
      
      request.headers.addAll(await _headers);
      request.files.add(await http.MultipartFile.fromPath('video', filePath));
      
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      
      return jsonDecode(responseString);
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  static Future<Map<String, dynamic>> uploadMaterial(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/material'),
      );
      
      request.headers.addAll(await _headers);
      request.files.add(await http.MultipartFile.fromPath('material', filePath));
      
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      
      return jsonDecode(responseString);
    } catch (e) {
      throw Exception('Failed to upload material: $e');
    }
  }

  // Payment Methods
  static Future<Map<String, dynamic>> processCoursePayment({
    required String courseId,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/process'),
        headers: await _headers,
        body: jsonEncode({
          'courseId': courseId,
          'paymentMethod': paymentMethod,
          'paymentDetails': paymentDetails ?? {},
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  static Future<Map<String, dynamic>> getPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment/history'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyPayment(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment/verify/$transactionId'),
        headers: await _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }
}