class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String> enrolledCourses;
  final List<String> completedCourses;
  final List<String> certificates;
  final int points;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'student',
    this.isActive = true,
    this.emailVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.enrolledCourses = const [],
    this.completedCourses = const [],
    this.certificates = const [],
    this.points = 0,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? map['displayName'] ?? '',
      role: map['role'] ?? 'student',
      isActive: map['isActive'] ?? true,
      emailVerified: map['emailVerified'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.tryParse(map['lastLoginAt'].toString())
          : null,
      enrolledCourses: List<String>.from(map['enrolledCourses'] ?? []),
      completedCourses: List<String>.from(map['completedCourses'] ?? []),
      certificates: List<String>.from(map['certificates'] ?? []),
      points: map['points'] ?? 0,
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'enrolledCourses': enrolledCourses,
      'completedCourses': completedCourses,
      'certificates': certificates,
      'points': points,
      'photoUrl': photoUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? enrolledCourses,
    List<String>? completedCourses,
    List<String>? certificates,
    int? points,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      completedCourses: completedCourses ?? this.completedCourses,
      certificates: certificates ?? this.certificates,
      points: points ?? this.points,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}