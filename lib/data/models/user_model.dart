class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? bio;
  final String? linkedIn;
  final String? twitter;
  final String role;
  final List<String> enrolledCourses;
  final List<String> completedCourses;
  final List<String> certificates;
  final DateTime createdAt;
  final DateTime? lastActive;
  final int points;
  final List<String> badges;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.bio,
    this.linkedIn,
    this.twitter,
    this.role = 'user',
    this.enrolledCourses = const [],
    this.completedCourses = const [],
    this.certificates = const [],
    required this.createdAt,
    this.lastActive,
    this.points = 0,
    this.badges = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'linkedIn': linkedIn,
      'twitter': twitter,
      'role': role,
      'enrolledCourses': enrolledCourses,
      'completedCourses': completedCourses,
      'certificates': certificates,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'points': points,
      'badges': badges,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      linkedIn: json['linkedIn'],
      twitter: json['twitter'],
      role: json['role'] ?? 'user',
      enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
      completedCourses: List<String>.from(json['completedCourses'] ?? []),
      certificates: List<String>.from(json['certificates'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      lastActive: json['lastActive'] != null 
          ? DateTime.parse(json['lastActive']) 
          : null,
      points: json['points'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? bio,
    String? linkedIn,
    String? twitter,
    String? role,
    List<String>? enrolledCourses,
    List<String>? completedCourses,
    List<String>? certificates,
    DateTime? createdAt,
    DateTime? lastActive,
    int? points,
    List<String>? badges,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      linkedIn: linkedIn ?? this.linkedIn,
      twitter: twitter ?? this.twitter,
      role: role ?? this.role,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      completedCourses: completedCourses ?? this.completedCourses,
      certificates: certificates ?? this.certificates,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      points: points ?? this.points,
      badges: badges ?? this.badges,
    );
  }
}