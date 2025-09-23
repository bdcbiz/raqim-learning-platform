import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service_factory.dart';
import '../auth/auth_interface.dart';
import '../../core/utils/logger.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8000/api/v1';
  static const String _webBaseUrl = 'http://localhost:8000/api/v1'; // For web platform

  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  ApiService._();

  // Auth service for token management
  late final AuthServiceInterface _authService;

  Future<void> initialize() async {
    await SharedPreferences.getInstance(); // Initialize prefs for future use
    _authService = AuthServiceFactory.createAuthService();
  }

  String get baseUrl {
    // Use different base URL for web platform
    if (Platform.isAndroid || Platform.isIOS) {
      return _baseUrl;
    }
    return _webBaseUrl;
  }

  /// Get headers with authentication token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    // Add auth token if available
    if (_authService.isAuthenticated && _authService.currentUser != null) {
      // For Laravel Sanctum, we would get the token from the user data
      // This is a placeholder - actual token management depends on auth implementation
      headers['Authorization'] = 'Bearer token_placeholder';
    }

    return headers;
  }

  /// Handle API response and errors
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final String responseBody = response.body;

    Logger.debug('API Response: ${response.statusCode}');
    Logger.debug('Response Body: $responseBody');

    try {
      final Map<String, dynamic> data = json.decode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      // Handle specific error codes
      switch (response.statusCode) {
        case 401:
          // Unauthorized - token expired or invalid
          await _authService.signOut();
          throw ApiException('انتهت صلاحية جلسة العمل، يرجى تسجيل الدخول مرة أخرى', 401);

        case 403:
          throw ApiException('ليس لديك صلاحية للوصول لهذا المحتوى', 403);

        case 404:
          throw ApiException('المورد المطلوب غير موجود', 404);

        case 422:
          // Validation errors
          final errors = data['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              throw ValidationException(firstError.first.toString(), errors);
            }
          }
          throw ApiException(data['message'] ?? 'خطأ في البيانات المدخلة', 422);

        case 429:
          throw ApiException('تم تجاوز عدد الطلبات المسموحة، يرجى المحاولة لاحقاً', 429);

        case 500:
          throw ApiException('خطأ في الخادم، يرجى المحاولة لاحقاً', 500);

        default:
          throw ApiException(
            data['message'] ?? 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
            response.statusCode
          );
      }
    } catch (e) {
      if (e is ApiException) rethrow;

      Logger.error('Failed to parse API response: $e');
      throw ApiException('خطأ في تحليل استجابة الخادم', response.statusCode);
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      String url = '$baseUrl$endpoint';

      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: queryParams).toString();
      }

      Logger.debug('GET Request: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت');
    } on HttpException {
      throw ApiException('خطأ في الاتصال بالخادم');
    } catch (e) {
      if (e is ApiException) rethrow;
      Logger.error('GET request failed: $e');
      throw ApiException('فشل في تنفيذ الطلب');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = '$baseUrl$endpoint';

      Logger.debug('POST Request: $url');
      Logger.debug('POST Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت');
    } on HttpException {
      throw ApiException('خطأ في الاتصال بالخادم');
    } catch (e) {
      if (e is ApiException) rethrow;
      Logger.error('POST request failed: $e');
      throw ApiException('فشل في تنفيذ الطلب');
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = '$baseUrl$endpoint';

      Logger.debug('PUT Request: $url');
      Logger.debug('PUT Body: ${json.encode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت');
    } on HttpException {
      throw ApiException('خطأ في الاتصال بالخادم');
    } catch (e) {
      if (e is ApiException) rethrow;
      Logger.error('PUT request failed: $e');
      throw ApiException('فشل في تنفيذ الطلب');
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';

      Logger.debug('DELETE Request: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت');
    } on HttpException {
      throw ApiException('خطأ في الاتصال بالخادم');
    } catch (e) {
      if (e is ApiException) rethrow;
      Logger.error('DELETE request failed: $e');
      throw ApiException('فشل في تنفيذ الطلب');
    }
  }

  /// Upload file (multipart request)
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
  }) async {
    try {
      final url = '$baseUrl$endpoint';

      Logger.debug('Upload Request: $url');
      Logger.debug('File Path: $filePath');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers (except Content-Type, which is set automatically for multipart)
      final headers = Map<String, String>.from(_headers);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت');
    } on HttpException {
      throw ApiException('خطأ في الاتصال بالخادم');
    } catch (e) {
      if (e is ApiException) rethrow;
      Logger.error('Upload request failed: $e');
      throw ApiException('فشل في رفع الملف');
    }
  }

  /// Check server health
  Future<bool> checkHealth() async {
    try {
      final response = await get('/health');
      return response['status'] == 'ok';
    } catch (e) {
      Logger.error('Health check failed: $e');
      return false;
    }
  }

  /// Retry request with exponential backoff
  Future<Map<String, dynamic>> retryRequest(
    Future<Map<String, dynamic>> Function() request, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          rethrow;
        }

        if (e is ApiException && e.statusCode == 401) {
          // Don't retry auth errors
          rethrow;
        }

        Logger.debug('Request failed, retrying in ${delay.inSeconds}s (attempt $attempt/$maxRetries)');

        await Future.delayed(delay);
        delay = Duration(seconds: (delay.inSeconds * 1.5).round());
      }
    }

    throw ApiException('فشل في تنفيذ الطلب بعد $maxRetries محاولات');
  }
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message ${statusCode != null ? '($statusCode)' : ''}';
}

/// Validation Exception class
class ValidationException extends ApiException {
  final Map<String, dynamic> errors;

  const ValidationException(String message, this.errors) : super(message, 422);

  String? getFieldError(String field) {
    final fieldErrors = errors[field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return null;
  }
}