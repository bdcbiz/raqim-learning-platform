import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'modern_card.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String? imageUrl;
  final int lessonsCount;
  final String duration;
  final String? price;
  final double? rating;
  final VoidCallback? onTap;
  final bool isWide;

  const CourseCard({
    Key? key,
    required this.title,
    required this.instructor,
    this.imageUrl,
    required this.lessonsCount,
    required this.duration,
    this.price,
    this.rating,
    this.onTap,
    this.isWide = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Course Image
          Container(
            height: isWide ? 100 : 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              color: AppColors.inputBackground,
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    ),
                  )
                : _buildPlaceholder(),
          ),

          // Course Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Instructor
                Text(
                  instructor,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Info Row with proper spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildInfoItem(
                          icon: Icons.play_circle_outline,
                          text: '$lessonsCount',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoItem(
                          icon: Icons.access_time,
                          text: duration,
                        ),
                        if (rating != null) ...[
                          const SizedBox(width: 8),
                          _buildInfoItem(
                            icon: Icons.star,
                            text: rating!.toString(),
                            iconColor: Colors.amber,
                          ),
                        ],
                      ],
                    ),
                    if (price != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: price == 'مجاني'
                              ? Colors.green.withValues(alpha: 0.1)
                              : AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          price!,
                          style: TextStyle(
                            color: price == 'مجاني'
                                ? Colors.green
                                : AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 12, color: iconColor ?? AppColors.secondaryText),
        const SizedBox(width: 2),
        Text(
          text,
          style: AppTextStyles.small.copyWith(
            color: AppColors.secondaryText,
            fontSize: 10,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Icon(
          Icons.play_circle_outline,
          size: 48,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}
