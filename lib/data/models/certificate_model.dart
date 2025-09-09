class CertificateModel {
  final String id;
  final String courseId;
  final String courseName;
  final String userId;
  final String userName;
  final String certificateNumber;
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final double finalGrade;
  final String status; // 'active', 'expired', 'revoked'
  final String certificateUrl;
  final Map<String, dynamic> courseDetails;
  final String instructorName;
  final int totalHours;
  final String level;

  CertificateModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.userId,
    required this.userName,
    required this.certificateNumber,
    required this.issuedDate,
    this.expiryDate,
    required this.finalGrade,
    this.status = 'active',
    required this.certificateUrl,
    required this.courseDetails,
    required this.instructorName,
    required this.totalHours,
    required this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'userId': userId,
      'userName': userName,
      'certificateNumber': certificateNumber,
      'issuedDate': issuedDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'finalGrade': finalGrade,
      'status': status,
      'certificateUrl': certificateUrl,
      'courseDetails': courseDetails,
      'instructorName': instructorName,
      'totalHours': totalHours,
      'level': level,
    };
  }

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      userId: json['userId'],
      userName: json['userName'],
      certificateNumber: json['certificateNumber'],
      issuedDate: DateTime.parse(json['issuedDate']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      finalGrade: json['finalGrade'].toDouble(),
      status: json['status'] ?? 'active',
      certificateUrl: json['certificateUrl'],
      courseDetails: json['courseDetails'] ?? {},
      instructorName: json['instructorName'],
      totalHours: json['totalHours'],
      level: json['level'],
    );
  }
}

class UserCourseProgress {
  final String userId;
  final String courseId;
  final List<String> completedLessons;
  final Map<String, double> quizScores;
  final double overallProgress;
  final DateTime lastAccessedDate;
  final DateTime enrolledDate;
  final bool isCompleted;
  final CertificateModel? certificate;

  UserCourseProgress({
    required this.userId,
    required this.courseId,
    required this.completedLessons,
    required this.quizScores,
    required this.overallProgress,
    required this.lastAccessedDate,
    required this.enrolledDate,
    this.isCompleted = false,
    this.certificate,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'courseId': courseId,
      'completedLessons': completedLessons,
      'quizScores': quizScores,
      'overallProgress': overallProgress,
      'lastAccessedDate': lastAccessedDate.toIso8601String(),
      'enrolledDate': enrolledDate.toIso8601String(),
      'isCompleted': isCompleted,
      'certificate': certificate?.toJson(),
    };
  }

  factory UserCourseProgress.fromJson(Map<String, dynamic> json) {
    return UserCourseProgress(
      userId: json['userId'],
      courseId: json['courseId'],
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      quizScores: Map<String, double>.from(json['quizScores'] ?? {}),
      overallProgress: json['overallProgress'].toDouble(),
      lastAccessedDate: DateTime.parse(json['lastAccessedDate']),
      enrolledDate: DateTime.parse(json['enrolledDate']),
      isCompleted: json['isCompleted'] ?? false,
      certificate: json['certificate'] != null 
          ? CertificateModel.fromJson(json['certificate'])
          : null,
    );
  }
}