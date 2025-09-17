class CourseModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String? promoVideoUrl;
  final String instructorId;
  final String instructorName;
  final String instructorBio;
  final String? instructorPhotoUrl;
  final String level;
  final String category;
  final List<String> objectives;
  final List<String> requirements;
  final List<CourseModule> modules;
  final double price;
  final double rating;
  final int totalRatings;
  final int enrolledStudents;
  final Duration totalDuration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFree;
  final String language;
  final List<Review> reviews;
  final bool isEnrolled;

  // Getter methods for backward compatibility
  int get duration => totalDuration.inHours;
  List<Lesson> get lessons => modules.expand((module) => module.lessons).toList();
  int get enrolledCount => enrolledStudents;
  int get reviewsCount => totalRatings;
  bool get isPublished => true; // All courses are published by default

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    this.promoVideoUrl,
    required this.instructorId,
    required this.instructorName,
    required this.instructorBio,
    this.instructorPhotoUrl,
    required this.level,
    required this.category,
    required this.objectives,
    required this.requirements,
    required this.modules,
    required this.price,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.enrolledStudents = 0,
    required this.totalDuration,
    required this.createdAt,
    required this.updatedAt,
    this.isFree = false,
    this.language = 'ar',
    this.reviews = const [],
    this.isEnrolled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'promoVideoUrl': promoVideoUrl,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'instructorBio': instructorBio,
      'instructorPhotoUrl': instructorPhotoUrl,
      'level': level,
      'category': category,
      'objectives': objectives,
      'requirements': requirements,
      'modules': modules.map((m) => m.toJson()).toList(),
      'price': price,
      'rating': rating,
      'totalRatings': totalRatings,
      'enrolledStudents': enrolledStudents,
      'totalDuration': totalDuration.inMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFree': isFree,
      'language': language,
      'reviews': reviews.map((r) => r.toJson()).toList(),
    };
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnail'] ?? 'https://picsum.photos/400/225',
      promoVideoUrl: json['promoVideoUrl'] ?? json['videoUrl'],
      instructorId: json['instructorId'] ?? json['instructor']?['_id'] ?? '',
      instructorName: json['instructorName'] ?? json['instructor']?['name'] ?? 'مدرس',
      instructorBio: json['instructorBio'] ?? json['instructor']?['bio'] ?? '',
      instructorPhotoUrl: json['instructorPhotoUrl'] ?? json['instructor']?['avatar'],
      level: json['level'] ?? 'مبتدئ',
      category: json['category'] ?? 'عام',
      objectives: json['objectives'] != null ? List<String>.from(json['objectives']) : [],
      requirements: json['requirements'] != null ? List<String>.from(json['requirements']) : [],
      modules: json['modules'] != null 
          ? (json['modules'] as List).map((m) => CourseModule.fromJson(m)).toList()
          : [],
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? json['ratingsCount'] ?? 0,
      enrolledStudents: json['enrolledStudents'] ?? json['studentsCount'] ?? 0,
      totalDuration: Duration(hours: json['duration'] ?? 1),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      isFree: json['isFree'] ?? json['price'] == 0 ?? false,
      language: json['language'] ?? 'ar',
      reviews: (json['reviews'] as List?)
              ?.map((r) => Review.fromJson(r))
              .toList() ??
          [],
      isEnrolled: json['isEnrolled'] ?? false,
    );
  }
}

class CourseModule {
  final String id;
  final String title;
  final List<Lesson> lessons;
  final Duration duration;

  CourseModule({
    required this.id,
    required this.title,
    required this.lessons,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lessons': lessons.map((l) => l.toJson()).toList(),
      'duration': duration.inMinutes,
    };
  }

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'],
      title: json['title'],
      lessons: (json['lessons'] as List)
          .map((l) => Lesson.fromJson(l))
          .toList(),
      duration: Duration(minutes: json['duration']),
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String? videoUrl;
  final String? content;
  final Duration duration;
  final List<String> resources;
  final Quiz? quiz;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    this.videoUrl,
    this.content,
    required this.duration,
    this.resources = const [],
    this.quiz,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'content': content,
      'duration': duration.inMinutes,
      'resources': resources,
      'quiz': quiz?.toJson(),
      'isCompleted': isCompleted,
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      videoUrl: json['videoUrl'],
      content: json['content'],
      duration: Duration(minutes: json['duration']),
      resources: List<String>.from(json['resources'] ?? []),
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Quiz {
  final String id;
  final List<Question> questions;
  final int passingScore;

  Quiz({
    required this.id,
    required this.questions,
    required this.passingScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questions': questions.map((q) => q.toJson()).toList(),
      'passingScore': passingScore,
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      passingScore: json['passingScore'],
    );
  }
}

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }
}

class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userPhotoUrl: json['userPhotoUrl'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

extension CourseModelExtensions on CourseModel {
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? promoVideoUrl,
    String? instructorId,
    String? instructorName,
    String? instructorBio,
    String? instructorPhotoUrl,
    String? level,
    String? category,
    List<String>? objectives,
    List<String>? requirements,
    List<CourseModule>? modules,
    double? price,
    double? rating,
    int? totalRatings,
    int? enrolledStudents,
    Duration? totalDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFree,
    String? language,
    List<Review>? reviews,
    bool? isEnrolled,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      promoVideoUrl: promoVideoUrl ?? this.promoVideoUrl,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      instructorBio: instructorBio ?? this.instructorBio,
      instructorPhotoUrl: instructorPhotoUrl ?? this.instructorPhotoUrl,
      level: level ?? this.level,
      category: category ?? this.category,
      objectives: objectives ?? this.objectives,
      requirements: requirements ?? this.requirements,
      modules: modules ?? this.modules,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      totalDuration: totalDuration ?? this.totalDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFree: isFree ?? this.isFree,
      language: language ?? this.language,
      reviews: reviews ?? this.reviews,
      isEnrolled: isEnrolled ?? this.isEnrolled,
    );
  }
}