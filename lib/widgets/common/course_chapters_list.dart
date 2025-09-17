import 'package:flutter/material.dart';
import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/widgets/common/course_chapter_card.dart';

class CourseChaptersList extends StatefulWidget {
  final List<ChapterData> chapters;
  final String courseTitle;
  final Function(int)? onChapterTap;

  const CourseChaptersList({
    Key? key,
    required this.chapters,
    required this.courseTitle,
    this.onChapterTap,
  }) : super(key: key);

  @override
  State<CourseChaptersList> createState() => _CourseChaptersListState();
}

class _CourseChaptersListState extends State<CourseChaptersList> {
  int activeChapterIndex = 0;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isMobile = screenWidth < 600;
    final filteredChapters = _filterChapters();

    if (isDesktop) {
      return _buildDesktopLayout(filteredChapters);
    } else {
      return _buildMobileLayout(filteredChapters);
    }
  }

  List<ChapterData> _filterChapters() {
    if (searchQuery.isEmpty) return widget.chapters;

    return widget.chapters.where((chapter) {
      return chapter.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
             chapter.subtitle.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildDesktopLayout(List<ChapterData> chapters) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildVideoPlayer(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: _buildChaptersSidebar(chapters),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<ChapterData> chapters) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildVideoPlayer(),
          const SizedBox(height: 16),
          _buildChaptersList(chapters, false),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final currentChapter = widget.chapters[activeChapterIndex];

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (currentChapter.thumbnailUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  currentChapter.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade900,
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white54,
                      size: 80,
                    ),
                  ),
                ),
              )
            else
              Container(
                color: Colors.grey.shade900,
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white54,
                  size: 80,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.black87,
                  size: 40,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  currentChapter.duration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChaptersSidebar(List<ChapterData> chapters) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSidebarHeader(isMobile),
          _buildSearchBar(),
          Flexible(
            child: _buildChaptersList(chapters, true),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'فصول الدورة',
                style: AppTextStyles.h3.copyWith(fontSize: isMobile ? 16 : 18),
              ),
              const SizedBox(height: 4),
              Text(
                'الفصل ${activeChapterIndex + 1} - المحتوى النهائي',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'عرض الكل',
              style: TextStyle(fontSize: isMobile ? 11 : 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'البحث في الفصول...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade500,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildChaptersList(List<ChapterData> chapters, bool inSidebar) {
    return ListView.builder(
      shrinkWrap: !inSidebar,
      physics: inSidebar ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final isActive = index == activeChapterIndex;
        final isCompleted = index < activeChapterIndex;
        final isLocked = chapter.isLocked;

        return CourseChapterCard(
          chapterNumber: 'الفصل ${index + 1}',
          title: chapter.title,
          subtitle: chapter.subtitle,
          duration: chapter.duration,
          thumbnailUrl: chapter.thumbnailUrl,
          instructorName: chapter.instructorName,
          instructorImage: chapter.instructorImage,
          isActive: isActive,
          isCompleted: isCompleted,
          isLocked: isLocked,
          onTap: () {
            if (!isLocked) {
              setState(() {
                activeChapterIndex = index;
              });
              widget.onChapterTap?.call(index);
            }
          },
        );
      },
    );
  }
}

class ChapterData {
  final String title;
  final String subtitle;
  final String duration;
  final String thumbnailUrl;
  final String videoUrl;
  final String instructorName;
  final String instructorImage;
  final bool isLocked;
  final Map<String, dynamic>? metadata;

  ChapterData({
    required this.title,
    required this.subtitle,
    required this.duration,
    this.thumbnailUrl = '',
    this.videoUrl = '',
    required this.instructorName,
    this.instructorImage = '',
    this.isLocked = false,
    this.metadata,
  });
}