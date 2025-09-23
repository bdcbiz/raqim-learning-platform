import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedCourseCard extends StatefulWidget {
  final String title;
  final String instructor;
  final String imageUrl;
  final String category;
  final int studentsCount;
  final double rating;
  final String price;
  final VoidCallback onTap;
  final Color categoryColor;

  const AnimatedCourseCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.imageUrl,
    required this.category,
    required this.studentsCount,
    required this.rating,
    required this.price,
    required this.onTap,
    this.categoryColor = const Color(0xFF10B981),
  });

  @override
  State<AnimatedCourseCard> createState() => _AnimatedCourseCardState();
}

class _AnimatedCourseCardState extends State<AnimatedCourseCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _shadowAnimation = Tween<double>(
      begin: 0.05,
      end: 0.15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _controller.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _controller.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _shadowAnimation.value),
                      blurRadius: 20,
                      offset: Offset(0, _isHovered ? 8 : 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with category badge
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              children: [
                                // Image with zoom effect
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  transform: Matrix4.identity()
                                    ..scale(_isHovered ? 1.05 : 1.0),
                                  transformAlignment: Alignment.center,
                                  child: Image.network(
                                    widget.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Overlay gradient on hover
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: _isHovered ? 0.3 : 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Category badge with slide animation
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          top: _isHovered ? 12 : 8,
                          right: _isHovered ? 12 : 8,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(
                              horizontal: _isHovered ? 12 : 8,
                              vertical: _isHovered ? 6 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.categoryColor,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: _isHovered
                                  ? [
                                      BoxShadow(
                                        color: widget.categoryColor.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              widget.category,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _isHovered ? 12 : 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Content with fixed height to prevent overflow
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Title
                                  Text(
                                    widget.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _isHovered
                                          ? widget.categoryColor
                                          : const Color(0xFF1F2937),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  // Instructor
                                  Text(
                                    widget.instructor,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isHovered
                                          ? Colors.grey[700]
                                          : Colors.grey[600],
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Stats row
                            Row(
                              children: [
                                // Students count
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 14,
                                      color: _isHovered
                                          ? widget.categoryColor
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${widget.studentsCount}+',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                // Rating
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Color(0xFFFFB800),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // Price
                                Text(
                                  widget.price,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: widget.price == 'مجاني'
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF6366F1),
                                    fontWeight: FontWeight.w600,
                                  ),
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
          },
        ),
      ),
    );
  }

  // Helper method to get category color
  static Color getCategoryColor(String category) {
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
}

class FullWidthCourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String imageUrl;
  final String category;
  final int studentsCount;
  final double rating;
  final String price;
  final VoidCallback onTap;
  final Color categoryColor;

  const FullWidthCourseCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.imageUrl,
    required this.category,
    required this.studentsCount,
    required this.rating,
    required this.price,
    required this.onTap,
    this.categoryColor = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
              child: Container(
                width: 120,
                height: 100,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                    // Category badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Instructor
                    Text(
                      instructor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stats and price row
                    Row(
                      children: [
                        // Students count
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${studentsCount}+',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Price
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 16,
                            color: price == 'مجاني'
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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