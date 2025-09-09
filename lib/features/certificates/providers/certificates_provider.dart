import 'package:flutter/material.dart';
import '../../../data/models/certificate_model.dart';

class CertificatesProvider extends ChangeNotifier {
  List<CertificateModel> _certificates = [];
  List<UserCourseProgress> _userProgress = [];
  bool _isLoading = false;
  String? _error;

  List<CertificateModel> get certificates => _certificates;
  List<UserCourseProgress> get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CertificatesProvider() {
    loadCertificates();
    loadUserProgress();
  }

  Future<void> loadCertificates() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _certificates = _generateMockCertificates();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل الشهادات: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProgress() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _userProgress = _generateMockProgress();
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل التقدم: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateLessonProgress(String courseId, String lessonId) async {
    final progressIndex = _userProgress.indexWhere((p) => p.courseId == courseId);
    if (progressIndex != -1) {
      final progress = _userProgress[progressIndex];
      if (!progress.completedLessons.contains(lessonId)) {
        final updatedLessons = [...progress.completedLessons, lessonId];
        
        // Calculate new progress percentage
        // Assuming each course has 10 lessons for simplicity
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

        // Issue certificate if course is completed
        if (newProgress >= 100 && progress.certificate == null) {
          await issueCertificate(courseId);
        }

        notifyListeners();
      }
    }
  }

  Future<void> issueCertificate(String courseId) async {
    final progress = _userProgress.firstWhere((p) => p.courseId == courseId);
    
    if (progress.overallProgress >= 100) {
      final certificate = CertificateModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        courseId: courseId,
        courseName: _getCourseNameById(courseId),
        userId: 'current_user',
        userName: 'محمد أحمد',
        certificateNumber: 'CERT-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        issuedDate: DateTime.now(),
        finalGrade: _calculateFinalGrade(progress.quizScores),
        certificateUrl: 'https://example.com/certificate/${courseId}',
        courseDetails: {
          'modules_completed': 10,
          'assignments_completed': 5,
          'quizzes_passed': progress.quizScores.length,
        },
        instructorName: 'د. أحمد محمد',
        totalHours: 12,
        level: 'مبتدئ',
      );

      _certificates.add(certificate);
      
      // Update progress with certificate
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
    // Simulate certificate download
    await Future.delayed(const Duration(seconds: 1));
    // In real app, this would download the certificate PDF
    debugPrint('Downloading certificate: $certificateId');
  }

  Future<void> shareCertificate(String certificateId) async {
    // Simulate certificate sharing
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, this would share the certificate via share dialog
    debugPrint('Sharing certificate: $certificateId');
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