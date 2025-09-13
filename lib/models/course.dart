class Course {
  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final String thumbnail;
  final Map<String, dynamic>? instructor;
  final List<String>? categories;
  final String category;
  final String level;
  final double price;
  final int totalLessons;
  final int totalStudents;
  final double rating;
  final int numberOfRatings;
  final Duration duration;
  final List<String> whatYouWillLearn;
  final List<String> requirements;
  final bool isFree;
  final bool isEnrolled;
  final String? enrolledAt;
  final String language;

  Course({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.thumbnail,
    this.instructor,
    this.categories,
    required this.category,
    required this.level,
    required this.price,
    required this.totalLessons,
    required this.totalStudents,
    required this.rating,
    required this.numberOfRatings,
    required this.duration,
    required this.whatYouWillLearn,
    required this.requirements,
    this.isFree = false,
    this.isEnrolled = false,
    this.enrolledAt,
    this.language = 'both',
  });

  String get instructorName => instructor?['name'] ?? 'Unknown';
  String get instructorAvatar => instructor?['avatar'] ?? '';
  
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      titleAr: json['titleAr'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      instructor: json['instructor'],
      categories: json['categories'] != null ? List<String>.from(json['categories']) : null,
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      totalLessons: json['totalLessons'] ?? 0,
      totalStudents: json['numberOfEnrollments'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      numberOfRatings: json['numberOfRatings'] ?? 0,
      duration: Duration(hours: json['duration'] ?? 0),
      whatYouWillLearn: List<String>.from(json['whatYouWillLearn'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      isFree: json['isFree'] ?? false,
      isEnrolled: json['isEnrolled'] ?? false,
      enrolledAt: json['enrolledAt'],
      language: json['language'] ?? 'both',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'titleAr': titleAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'thumbnail': thumbnail,
      'instructor': instructor,
      'categories': categories,
      'category': category,
      'level': level,
      'price': price,
      'totalLessons': totalLessons,
      'numberOfEnrollments': totalStudents,
      'rating': rating,
      'numberOfRatings': numberOfRatings,
      'duration': duration.inHours,
      'whatYouWillLearn': whatYouWillLearn,
      'requirements': requirements,
      'isFree': isFree,
      'isEnrolled': isEnrolled,
      'enrolledAt': enrolledAt,
      'language': language,
    };
  }

  Course copyWith({
    bool? isEnrolled,
    String? enrolledAt,
  }) {
    return Course(
      id: id,
      title: title,
      titleAr: titleAr,
      description: description,
      descriptionAr: descriptionAr,
      thumbnail: thumbnail,
      instructor: instructor,
      categories: categories,
      category: category,
      level: level,
      price: price,
      totalLessons: totalLessons,
      totalStudents: totalStudents,
      rating: rating,
      numberOfRatings: numberOfRatings,
      duration: duration,
      whatYouWillLearn: whatYouWillLearn,
      requirements: requirements,
      isFree: isFree,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      language: language,
    );
  }
}