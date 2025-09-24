import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class UnifiedCourseCard extends StatefulWidget {
  final dynamic course;
  final VoidCallback onTap;
  final bool showProgress;
  final double? progress;

  const UnifiedCourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.showProgress = false,
    this.progress,
  });

  @override
  State<UnifiedCourseCard> createState() => _UnifiedCourseCardState();
}

class _UnifiedCourseCardState extends State<UnifiedCourseCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  double get _price {
    if (widget.course is Map) {
      var price = widget.course['price'];
      if (price is String) {
        // Extract number from string like "299 ر.س" or "مجاني"
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
    // Course model has totalLessons
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
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.08),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: Offset(0, _isHovered ? 6 : 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section with Badges
                    Stack(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
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
                                ),
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

                                // Gradient overlay for better text readability
                                if (_isHovered)
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Top badges
                        Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Category badge
                              if (_category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(_category),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _category!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              // Price badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _price == 0 ? Colors.green : Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _price == 0 ? 'مجاني' : '${_price.toInt()} ريال',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Level badge
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Content Section
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Flexible(
                              child: Text(
                                _title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Instructor
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: AppColors.secondaryText,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _instructorName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondaryText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Stats row
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
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        _rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Duration
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: AppColors.secondaryText,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _duration,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.secondaryText,
                                  ),
                                ),

                                const Spacer(),

                                // Lessons count
                                Icon(
                                  Icons.play_lesson,
                                  size: 12,
                                  color: AppColors.secondaryText,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$_lessonsCount درس',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.secondaryText,
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
          },
        ),
      ),
    );
  }
}