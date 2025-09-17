import 'package:flutter/material.dart';
import 'package:raqim/core/theme/app_colors.dart';
import 'package:raqim/core/theme/app_text_styles.dart';

class CourseChapterCard extends StatelessWidget {
  final String chapterNumber;
  final String title;
  final String subtitle;
  final String duration;
  final String thumbnailUrl;
  final String instructorName;
  final String instructorImage;
  final VoidCallback onTap;
  final bool isCompleted;
  final bool isLocked;
  final bool isActive;

  const CourseChapterCard({
    Key? key,
    required this.chapterNumber,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.thumbnailUrl,
    required this.instructorName,
    required this.instructorImage,
    required this.onTap,
    this.isCompleted = false,
    this.isLocked = false,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: isActive ? 2 : 0.5,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isActive
                ? Border.all(color: AppColors.primaryColor, width: 2)
                : Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                _buildThumbnail(isMobile),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(isMobile),
                        const SizedBox(height: 4),
                        _buildTitle(isMobile),
                        const SizedBox(height: 4),
                        _buildSubtitle(isMobile),
                        const SizedBox(height: 12),
                        _buildFooter(isMobile),
                      ],
                    ),
                  ),
                ),
                if (isDesktop) _buildStatusIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isMobile) {
    return Container(
      width: isMobile ? 100 : 140,
      height: isMobile ? 75 : 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
        color: Colors.grey.shade200,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            child: thumbnailUrl.isNotEmpty
              ? Image.network(
                  thumbnailUrl,
                  width: 140,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
          ),
          if (isLocked)
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                color: Colors.black54,
              ),
              child: const Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          if (!isLocked && !isCompleted)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  duration,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 9 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(
        Icons.play_circle_outline,
        color: Colors.grey.shade500,
        size: 40,
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Text(
      chapterNumber,
      style: TextStyle(
        fontSize: isMobile ? 10 : 12,
        fontWeight: FontWeight.w500,
        color: isActive ? AppColors.primaryColor : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildTitle(bool isMobile) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: isMobile ? 14 : 16,
        color: isLocked ? Colors.grey.shade500 : Colors.black87,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(bool isMobile) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: isMobile ? 11 : 13,
        color: Colors.grey.shade600,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: instructorImage.isNotEmpty
            ? NetworkImage(instructorImage)
            : null,
          child: instructorImage.isEmpty
            ? Icon(Icons.person, size: 16, color: Colors.grey.shade600)
            : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            instructorName,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon() {
    if (isCompleted) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 20,
          ),
        ),
      );
    } else if (isActive) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
      );
    } else if (isLocked) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          Icons.lock_outline,
          color: Colors.grey.shade400,
          size: 20,
        ),
      );
    }
    return const SizedBox(width: 16);
  }
}