import 'package:flutter/material.dart';
import '../../../data/models/certificate_model.dart';
import '../../../services/api/api_service.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/handlers/error_handler.dart';

class CertificatesProvider extends ChangeNotifier {
  List<CertificateModel> _certificates = [];
  List<UserCourseProgress> _userProgress = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService.instance;

  List<CertificateModel> get certificates => _certificates;
  List<UserCourseProgress> get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CertificatesProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _apiService.initialize();
    await loadCertificates();
    await loadUserProgress();
  }

  Future<void> loadCertificates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ErrorHandler.safeAsyncCall<List<CertificateModel>>(
      () async {
        final response = await _apiService.get('/certificates');

        if (response['data'] != null) {
          final certificatesData = response['data'] as List;
          return certificatesData.map((certJson) => _convertApiResponseToCertificate(certJson)).toList();
        } else {
          throw const NetworkException('Invalid API response structure', code: 'invalid_response');
        }
      },
      context: 'Loading certificates',
      fallbackValue: _generateMockCertificates(),
    );

    _certificates = result ?? _generateMockCertificates();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserProgress() async {
    final result = await ErrorHandler.safeAsyncCall<List<UserCourseProgress>>(
      () async {
        final response = await _apiService.get('/user/progress');

        if (response['data'] != null) {
          final progressData = response['data'] as List;
          return progressData.map((progressJson) => _convertApiResponseToProgress(progressJson)).toList();
        } else {
          throw const NetworkException('Invalid API response structure', code: 'invalid_response');
        }
      },
      context: 'Loading user progress',
      fallbackValue: _generateMockProgress(),
    );

    _userProgress = result ?? _generateMockProgress();
    notifyListeners();
  }

  Future<void> updateLessonProgress(String courseId, String lessonId) async {
    final progressIndex = _userProgress.indexWhere((p) => p.courseId == courseId);
    if (progressIndex == -1) return;

    final progress = _userProgress[progressIndex];
    if (progress.completedLessons.contains(lessonId)) return;

    final updatedLessons = [...progress.completedLessons, lessonId];
    final newProgress = (updatedLessons.length / 10) * 100;

    _userProgress[progressIndex] = UserCourseProgress(
      userId: progress.userId,
      courseId: progress.courseId,
      completedLessons: updatedLessons,
      quizScores: progress.quizScores,
      overallProgress: newProgress,
      lastAccessedDate: DateTime.now(),
      enrolledDate: progress.enrolledDate,
      isCompleted: newProgress >= 100,
      certificate: progress.certificate,
    );
    notifyListeners();

    await ErrorHandler.safeAsyncCall<void>(
      () async {
        await _apiService.post('/user/progress/lesson', body: {
          'course_id': courseId,
          'lesson_id': lessonId,
        });
      },
      context: 'Updating lesson progress',
      showError: false,
    );

    if (newProgress >= 100 && progress.certificate == null) {
      await issueCertificate(courseId);
    }
  }

  Future<void> issueCertificate(String courseId) async {
    final progress = _userProgress.firstWhere((p) => p.courseId == courseId);

    if (progress.overallProgress < 100) return;

    final result = await ErrorHandler.safeAsyncCall<Map<String, dynamic>>(
      () async {
        final response = await _apiService.post('/certificates/issue', body: {
          'course_id': courseId,
          'user_id': progress.userId,
          'final_grade': _calculateFinalGrade(progress.quizScores),
        });

        if (response['data'] != null) {
          return response['data'];
        } else {
          throw const BusinessLogicException('Failed to issue certificate', code: 'certificate_issue_failed');
        }
      },
      context: 'Issuing certificate',
      fallbackValue: null,
    );

    CertificateModel certificate;
    if (result != null) {
      certificate = _convertApiResponseToCertificate(result);
    } else {
      certificate = CertificateModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        courseId: courseId,
        courseName: _getCourseNameById(courseId),
        userId: 'current_user',
        userName: 'محمد أحمد',
        certificateNumber: 'CERT-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        issuedDate: DateTime.now(),
        finalGrade: _calculateFinalGrade(progress.quizScores),
        certificateUrl: 'https://example.com/certificate/$courseId',
        courseDetails: {
          'modules_completed': 10,
          'assignments_completed': 5,
          'quizzes_passed': progress.quizScores.length,
        },
        instructorName: 'د. أحمد محمد',
        totalHours: 12,
        level: 'مبتدئ',
      );
    }

    _certificates.add(certificate);

    final progressIndex = _userProgress.indexWhere((p) => p.courseId == courseId);
    if (progressIndex != -1) {
      _userProgress[progressIndex] = UserCourseProgress(
        userId: progress.userId,
        courseId: progress.courseId,
        completedLessons: progress.completedLessons,
        quizScores: progress.quizScores,
        overallProgress: progress.overallProgress,
        lastAccessedDate: progress.lastAccessedDate,
        enrolledDate: progress.enrolledDate,
        isCompleted: true,
        certificate: certificate,
      );
    }

    notifyListeners();
  }

  double _calculateFinalGrade(Map<String, double> quizScores) {
    if (quizScores.isEmpty) return 85.0; // Default grade if no quizzes
    final total = quizScores.values.reduce((a, b) => a + b);
    return total / quizScores.length;
  }

  String _getCourseNameById(String courseId) {
    switch (courseId) {
      case '1':
        return 'أساسيات تعلم الآلة للمبتدئين';
      case '2':
        return 'معالجة اللغات الطبيعية المتقدمة';
      case '3':
        return 'رؤية الحاسوب والتعلم العميق';
      default:
        return 'دورة تدريبية';
    }
  }

  Future<void> downloadCertificate(String certificateId) async {
    try {
      await _apiService.get('/certificates/$certificateId/download');
      debugPrint('Certificate downloaded successfully: $certificateId');
    } catch (e) {
      print('Error downloading certificate: $e');
      // Simulate certificate download as fallback
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Certificate download simulated: $certificateId');
    }
  }

  Future<void> shareCertificate(String certificateId) async {
    try {
      await _apiService.post('/certificates/$certificateId/share');
      debugPrint('Certificate shared successfully: $certificateId');
    } catch (e) {
      print('Error sharing certificate: $e');
      // Simulate certificate sharing as fallback
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Certificate sharing simulated: $certificateId');
    }
  }

  CertificateModel _convertApiResponseToCertificate(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'].toString(),
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      certificateNumber: json['certificate_number'] ?? '',
      issuedDate: DateTime.tryParse(json['issued_at'] ?? '') ?? DateTime.now(),
      finalGrade: (json['final_grade'] ?? 0).toDouble(),
      certificateUrl: json['certificate_url'] ?? '',
      courseDetails: json['course_details'] ?? {},
      instructorName: json['instructor_name'] ?? 'غير محدد',
      totalHours: json['total_hours'] ?? 0,
      level: json['level'] ?? 'مبتدئ',
    );
  }

  UserCourseProgress _convertApiResponseToProgress(Map<String, dynamic> json) {
    return UserCourseProgress(
      userId: json['user_id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      completedLessons: (json['completed_lessons'] as List?)?.map((e) => e.toString()).toList() ?? [],
      quizScores: Map<String, double>.from(json['quiz_scores'] ?? {}),
      overallProgress: (json['overall_progress'] ?? 0).toDouble(),
      lastAccessedDate: DateTime.tryParse(json['last_accessed_at'] ?? '') ?? DateTime.now(),
      enrolledDate: DateTime.tryParse(json['enrolled_at'] ?? '') ?? DateTime.now(),
      isCompleted: json['is_completed'] ?? false,
      certificate: json['certificate'] != null ? _convertApiResponseToCertificate(json['certificate']) : null,
    );
  }

  List<CertificateModel> _generateMockCertificates() {
    return [
      CertificateModel(
        id: '1',
        courseId: '1',
        courseName: 'أساسيات تعلم الآلة للمبتدئين',
        userId: 'current_user',
        userName: 'محمد أحمد',
        certificateNumber: 'CERT-2024-001234',
        issuedDate: DateTime.now().subtract(const Duration(days: 30)),
        finalGrade: 92.5,
        certificateUrl: 'https://example.com/certificate/1',
        courseDetails: {
          'modules_completed': 12,
          'assignments_completed': 8,
          'quizzes_passed': 10,
        },
        instructorName: 'د. أحمد محمد',
        totalHours: 12,
        level: 'مبتدئ',
      ),
      CertificateModel(
        id: '2',
        courseId: '3',
        courseName: 'رؤية الحاسوب والتعلم العميق',
        userId: 'current_user',
        userName: 'محمد أحمد',
        certificateNumber: 'CERT-2024-002345',
        issuedDate: DateTime.now().subtract(const Duration(days: 10)),
        finalGrade: 88.0,
        certificateUrl: 'https://example.com/certificate/2',
        courseDetails: {
          'modules_completed': 15,
          'assignments_completed': 10,
          'quizzes_passed': 12,
        },
        instructorName: 'م. خالد عبدالله',
        totalHours: 18,
        level: 'متوسط',
      ),
    ];
  }

  List<UserCourseProgress> _generateMockProgress() {
    return [
      UserCourseProgress(
        userId: 'current_user',
        courseId: '1',
        completedLessons: ['l1', 'l2', 'l3', 'l4', 'l5', 'l6', 'l7', 'l8', 'l9', 'l10'],
        quizScores: {
          'quiz1': 95.0,
          'quiz2': 90.0,
          'quiz3': 92.5,
        },
        overallProgress: 100,
        lastAccessedDate: DateTime.now().subtract(const Duration(days: 30)),
        enrolledDate: DateTime.now().subtract(const Duration(days: 60)),
        isCompleted: true,
      ),
      UserCourseProgress(
        userId: 'current_user',
        courseId: '2',
        completedLessons: ['l1', 'l2', 'l3', 'l4'],
        quizScores: {
          'quiz1': 85.0,
        },
        overallProgress: 40,
        lastAccessedDate: DateTime.now().subtract(const Duration(days: 2)),
        enrolledDate: DateTime.now().subtract(const Duration(days: 15)),
        isCompleted: false,
      ),
      UserCourseProgress(
        userId: 'current_user',
        courseId: '3',
        completedLessons: ['l1', 'l2', 'l3', 'l4', 'l5', 'l6', 'l7', 'l8', 'l9', 'l10'],
        quizScores: {
          'quiz1': 88.0,
          'quiz2': 86.0,
          'quiz3': 90.0,
        },
        overallProgress: 100,
        lastAccessedDate: DateTime.now().subtract(const Duration(days: 10)),
        enrolledDate: DateTime.now().subtract(const Duration(days: 45)),
        isCompleted: true,
      ),
    ];
  }
}