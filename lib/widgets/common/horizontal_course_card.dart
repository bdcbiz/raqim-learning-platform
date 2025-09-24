import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HorizontalCourseCard extends StatefulWidget {
  final dynamic course;
  final VoidCallback onTap;
  final bool showProgress;
  final double? progress;

  const HorizontalCourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.showProgress = false,
    this.progress,
  });

  @override
  State<HorizontalCourseCard> createState() => _HorizontalCourseCardState();
}

class _HorizontalCourseCardState extends State<HorizontalCourseCard> {
  String get _title {
    if (widget.course is Map) {
      return widget.course['titleAr'] ?? widget.course['title'] ?? '';
    }
    return widget.course.titleAr ?? widget.course.title ?? '';
  }

  String get _instructorName {
    if (widget.course is Map) {
      return widget.course['instructorName'] ?? widget.course['instructor'] ?? '';
    }
    // For Course model, instructor is a Map
    if (widget.course.instructor != null && widget.course.instructor is Map) {
      return widget.course.instructor['name'] ?? 'مدرب رقيم';
    }
    return 'مدرب رقيم';
  }

  String? get _thumbnail {
    if (widget.course is Map) {
      return widget.course['thumbnailUrl'] ?? widget.course['thumbnail'] ?? widget.course['image'];
    }
    return widget.course.thumbnail;
  }

  String? get _category {
    if (widget.course is Map) {
      return widget.course['category'];
    }
    return widget.course.category;
  }

  String get _description {
    if (widget.course is Map) {
      return widget.course['descriptionAr'] ?? widget.course['description'] ?? 'دورة متميزة في مجال الذكاء الاصطناعي وتعلم الآلة';
    }
    return widget.course.descriptionAr ?? widget.course.description ?? 'دورة متميزة في مجال الذكاء الاصطناعي وتعلم الآلة';
  }

  double get _price {
    if (widget.course is Map) {
      var price = widget.course['price'];
      if (price is String) {
        if (price == 'مجاني') return 0.0;
        return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      }
      return (price ?? 0).toDouble();
    }
    return (widget.course.price ?? 0).toDouble();
  }

  double get _rating {
    if (widget.course is Map) {
      var rating = widget.course['rating'];
      if (rating is String) {
        return double.tryParse(rating) ?? 4.5;
      }
      return (rating ?? 4.5).toDouble();
    }
    return (widget.course.rating ?? 4.5).toDouble();
  }

  int get _lessonsCount {
    if (widget.course is Map) {
      var lessons = widget.course['lessonsCount'] ?? widget.course['lessons'] ?? widget.course['totalLessons'] ?? widget.course['modules']?.length;
      if (lessons is String) {
        return int.tryParse(lessons) ?? 0;
      }
      return lessons ?? 12;
    }
    return widget.course.totalLessons ?? 12;
  }

  String get _duration {
    if (widget.course is Map) {
      return widget.course['duration'] ?? '12 ساعة';
    }
    // Course model has Duration type
    if (widget.course.duration != null) {
      int hours = widget.course.duration.inHours;
      if (hours > 0) {
        return '$hours ساعة';
      }
    }
    return '12 ساعة';
  }

  String get _level {
    if (widget.course is Map) {
      return widget.course['level'] ?? 'مبتدئ';
    }
    return widget.course.level ?? 'مبتدئ';
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
      case 'الذكاء التوليدي':
        return const Color(0xFFDC2626);
      case 'الأعمال':
      case 'business':
        return const Color(0xFF7C3AED);
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

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'مبتدئ':
        return Colors.green;
      case 'intermediate':
      case 'متوسط':
        return Colors.orange;
      case 'advanced':
      case 'متقدم':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Container(
                width: 140,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(_category).withOpacity(0.3),
                      _getCategoryColor(_category).withOpacity(0.1),
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_thumbnail != null && _thumbnail!.isNotEmpty)
                      Image.network(
                        _thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: _getCategoryColor(_category),
                            ),
                          );
                        },
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 48,
                          color: _getCategoryColor(_category),
                        ),
                      ),

                  ],
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and Level
                    Row(
                      children: [
                        if (_category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(_category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _category!,
                              style: TextStyle(
                                color: _getCategoryColor(_category),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getLevelColor(_level).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.signal_cellular_alt,
                                size: 12,
                                color: _getLevelColor(_level),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getLevelText(_level),
                                style: TextStyle(
                                  color: _getLevelColor(_level),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title and Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
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
                        ),
                        const SizedBox(width: 12),
                        // Price Badge - Large and Clear
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _price == 0 ? Colors.green : AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (_price == 0 ? Colors.green : AppColors.primaryColor).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _price == 0 ? 'مجاني' : '${_price.toInt()} ريال',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Description
                    Text(
                      _description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Instructor
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _instructorName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Bottom Stats Row
                    Row(
                      children: [
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Duration
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _duration,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Lessons
                        Row(
                          children: [
                            Icon(
                              Icons.play_lesson,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_lessonsCount درس',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Enroll Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(_category),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'التسجيل',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Progress bar if needed
                    if (widget.showProgress && widget.progress != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.progress! / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(_category),
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مكتمل ${widget.progress!.toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}