import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ElegantCourseCard extends StatelessWidget {
  final dynamic course;
  final VoidCallback onTap;

  const ElegantCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  String get _title {
    if (course is Map) {
      return course['titleAr'] ?? course['title'] ?? '';
    }
    return course.titleAr ?? course.title ?? '';
  }

  String get _instructorName {
    if (course is Map) {
      return course['instructorName'] ?? course['instructor'] ?? 'مدرب رقيم';
    }
    if (course.instructor != null && course.instructor is Map) {
      return course.instructor['name'] ?? 'مدرب رقيم';
    }
    return 'مدرب رقيم';
  }

  String? get _thumbnail {
    if (course is Map) {
      return course['thumbnailUrl'] ?? course['thumbnail'] ?? course['image'];
    }
    return course.thumbnail;
  }

  String? get _category {
    if (course is Map) {
      return course['category'];
    }
    return course.category;
  }

  double get _price {
    if (course is Map) {
      var price = course['price'];
      if (price is String) {
        if (price == 'مجاني') return 0.0;
        return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      }
      return (price ?? 0).toDouble();
    }
    return (course.price ?? 0).toDouble();
  }

  double get _rating {
    if (course is Map) {
      var rating = course['rating'];
      if (rating is String) {
        return double.tryParse(rating) ?? 4.5;
      }
      return (rating ?? 4.5).toDouble();
    }
    return (course.rating ?? 4.5).toDouble();
  }

  int get _lessonsCount {
    if (course is Map) {
      var lessons = course['lessonsCount'] ?? course['lessons'] ?? course['totalLessons'] ?? 15;
      if (lessons is String) {
        return int.tryParse(lessons) ?? 15;
      }
      return lessons ?? 15;
    }
    return course.totalLessons ?? 15;
  }

  String get _duration {
    if (course is Map) {
      return course['duration'] ?? '12 ساعة';
    }
    if (course.duration != null) {
      int hours = course.duration.inHours;
      if (hours > 0) {
        return '$hours ساعة';
      }
    }
    return '12 ساعة';
  }

  String get _level {
    if (course is Map) {
      return course['level'] ?? 'مبتدئ';
    }
    return course.level ?? 'مبتدئ';
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'تعلم الآلة':
      case 'Machine Learning':
        return const Color(0xFF3B82F6);
      case 'معالجة اللغات':
      case 'NLP':
        return const Color(0xFFEF4444);
      case 'رؤية الحاسوب':
      case 'Computer Vision':
        return const Color(0xFF10B981);
      case 'التعلم العميق':
      case 'Deep Learning':
        return const Color(0xFF8B5CF6);
      case 'علم البيانات':
      case 'Data Science':
        return const Color(0xFFF59E0B);
      case 'البرمجة':
      case 'programming':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _getLevelText(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section with Image
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(_category).withOpacity(0.3),
                    _getCategoryColor(_category).withOpacity(0.1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Course Image
                  if (_thumbnail != null && _thumbnail!.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        _thumbnail!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getCategoryColor(_category).withOpacity(0.2),
                                  _getCategoryColor(_category).withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                size: 60,
                                color: _getCategoryColor(_category),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getCategoryColor(_category).withOpacity(0.2),
                            _getCategoryColor(_category).withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 60,
                          color: _getCategoryColor(_category),
                        ),
                      ),
                    ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),

                  // Category Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(_category),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _category ?? 'تعلم الآلة',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(_category),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Info Row
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        // Level Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getLevelText(_level),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Duration
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time, size: 12, color: Colors.black87),
                              const SizedBox(width: 4),
                              Text(
                                _duration,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Instructor Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _instructorName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats Row
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            _rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Lessons
                      Row(
                        children: [
                          const Icon(Icons.play_lesson, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '$_lessonsCount درس',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  const SizedBox(height: 12),

                  // Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السعر',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _price == 0 ? 'مجاني' : '${_price.toInt()} ريال',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _price == 0 ? Colors.green : AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}