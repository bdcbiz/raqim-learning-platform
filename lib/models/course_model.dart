class CourseModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String instructor;
  final String thumbnailUrl;
  final double price;
  final int enrolledCount;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int duration;
  final String level;
  final double rating;
  final int reviewsCount;
  final List<String> lessons;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.instructor,
    this.thumbnailUrl = '',
    required this.price,
    this.enrolledCount = 0,
    this.isPublished = false,
    required this.createdAt,
    this.updatedAt,
    this.duration = 0,
    this.level = 'مبتدئ',
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.lessons = const [],
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      instructor: map['instructor'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      enrolledCount: map['enrolledCount'] ?? 0,
      isPublished: map['isPublished'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
      duration: map['duration'] ?? 0,
      level: map['level'] ?? 'مبتدئ',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      lessons: List<String>.from(map['lessons'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'instructor': instructor,
      'thumbnailUrl': thumbnailUrl,
      'price': price,
      'enrolledCount': enrolledCount,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'duration': duration,
      'level': level,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'lessons': lessons,
    };
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? instructor,
    String? thumbnailUrl,
    double? price,
    int? enrolledCount,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? duration,
    String? level,
    double? rating,
    int? reviewsCount,
    List<String>? lessons,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      instructor: instructor ?? this.instructor,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      price: price ?? this.price,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      lessons: lessons ?? this.lessons,
    );
  }
}