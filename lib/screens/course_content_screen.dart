import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/theme/app_theme.dart';

class CourseContentScreen extends StatefulWidget {
  final Course course;

  const CourseContentScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  int _selectedModuleIndex = 0;
  int _selectedLessonIndex = 0;
  bool _isVideoPlaying = false;

  // Mock course modules and lessons
  final List<Map<String, dynamic>> _modules = [
    {
      'id': '1',
      'title': 'المقدمة والأساسيات',
      'lessons': [
        {
          'id': '1',
          'title': 'مقدمة في الذكاء الاصطناعي',
          'duration': '15:30',
          'type': 'video',
          'completed': true,
          'videoUrl': 'https://example.com/video1.mp4',
        },
        {
          'id': '2',
          'title': 'تاريخ وتطور الذكاء الاصطناعي',
          'duration': '20:45',
          'type': 'video',
          'completed': true,
          'videoUrl': 'https://example.com/video2.mp4',
        },
        {
          'id': '3',
          'title': 'التطبيقات العملية',
          'duration': '18:20',
          'type': 'video',
          'completed': false,
          'videoUrl': 'https://example.com/video3.mp4',
        },
        {
          'id': '4',
          'title': 'اختبار الوحدة الأولى',
          'duration': '10:00',
          'type': 'quiz',
          'completed': false,
          'questions': 10,
        },
      ],
    },
    {
      'id': '2',
      'title': 'تعلم الآلة الأساسي',
      'lessons': [
        {
          'id': '5',
          'title': 'مفاهيم تعلم الآلة',
          'duration': '25:00',
          'type': 'video',
          'completed': false,
          'videoUrl': 'https://example.com/video5.mp4',
        },
        {
          'id': '6',
          'title': 'الخوارزميات الأساسية',
          'duration': '30:15',
          'type': 'video',
          'completed': false,
          'videoUrl': 'https://example.com/video6.mp4',
        },
        {
          'id': '7',
          'title': 'التدريب العملي',
          'duration': '45:00',
          'type': 'practice',
          'completed': false,
        },
      ],
    },
    {
      'id': '3',
      'title': 'التعلم العميق',
      'lessons': [
        {
          'id': '8',
          'title': 'الشبكات العصبية',
          'duration': '35:20',
          'type': 'video',
          'completed': false,
          'videoUrl': 'https://example.com/video8.mp4',
        },
        {
          'id': '9',
          'title': 'معالجة الصور',
          'duration': '40:30',
          'type': 'video',
          'completed': false,
          'videoUrl': 'https://example.com/video9.mp4',
        },
        {
          'id': '10',
          'title': 'المشروع النهائي',
          'duration': '60:00',
          'type': 'project',
          'completed': false,
        },
      ],
    },
  ];

  double get _courseProgress {
    int totalLessons = 0;
    int completedLessons = 0;

    for (var module in _modules) {
      final lessons = module['lessons'] as List;
      totalLessons += lessons.length;
      completedLessons += lessons.where((l) => l['completed'] == true).length;
    }

    return totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;
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
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getLessonIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_filled;
      case 'quiz':
        return Icons.quiz;
      case 'practice':
        return Icons.code;
      case 'project':
        return Icons.assignment;
      default:
        return Icons.article;
    }
  }

  Color _getLessonIconColor(String type) {
    switch (type) {
      case 'video':
        return Colors.red;
      case 'quiz':
        return Colors.orange;
      case 'practice':
        return Colors.blue;
      case 'project':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final selectedModule = _modules[_selectedModuleIndex];
    final selectedLesson = selectedModule['lessons'][_selectedLessonIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.course.titleAr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'التقدم: ${_courseProgress.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          // Progress indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _courseProgress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCategoryColor(widget.course.category),
                ),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar - Module List
          if (!isMobile || !_isVideoPlaying)
            Container(
              width: isMobile ? MediaQuery.of(context).size.width : 320,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Course Stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.course.category).withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: _getCategoryColor(widget.course.category).withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: _buildStatItem(Icons.video_library, '${widget.course.totalLessons} درس'),
                        ),
                        Flexible(
                          child: _buildStatItem(Icons.access_time, '${widget.course.duration.inHours} ساعة'),
                        ),
                        Flexible(
                          child: _buildStatItem(Icons.check_circle, '${_courseProgress.toInt()}%'),
                        ),
                      ],
                    ),
                  ),
                  // Modules List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _modules.length,
                      itemBuilder: (context, moduleIndex) {
                        final module = _modules[moduleIndex];
                        final lessons = module['lessons'] as List;
                        final completedLessons = lessons.where((l) => l['completed'] == true).length;
                        final isExpanded = _selectedModuleIndex == moduleIndex;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isExpanded ? _getCategoryColor(widget.course.category).withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isExpanded
                                  ? _getCategoryColor(widget.course.category).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: isExpanded,
                              onExpansionChanged: (expanded) {
                                if (expanded) {
                                  setState(() {
                                    _selectedModuleIndex = moduleIndex;
                                    _selectedLessonIndex = 0;
                                  });
                                }
                              },
                              title: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(widget.course.category).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${moduleIndex + 1}',
                                        style: TextStyle(
                                          color: _getCategoryColor(widget.course.category),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          module['title'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$completedLessons من ${lessons.length} مكتمل',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              children: lessons.asMap().entries.map((entry) {
                                final lessonIndex = entry.key;
                                final lesson = entry.value;
                                final isSelected = moduleIndex == _selectedModuleIndex &&
                                                 lessonIndex == _selectedLessonIndex;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedModuleIndex = moduleIndex;
                                      _selectedLessonIndex = lessonIndex;
                                      if (isMobile) {
                                        _isVideoPlaying = true;
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _getCategoryColor(widget.course.category).withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border(
                                        right: BorderSide(
                                          color: isSelected
                                              ? _getCategoryColor(widget.course.category)
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          lesson['completed'] ? Icons.check_circle : Icons.circle_outlined,
                                          size: 20,
                                          color: lesson['completed']
                                              ? Colors.green
                                              : Colors.grey[400],
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          _getLessonIcon(lesson['type']),
                                          size: 20,
                                          color: _getLessonIconColor(lesson['type']),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lesson['title'],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                lesson['duration'],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Main Content - Video/Lesson Player
          if (!isMobile || _isVideoPlaying)
            Expanded(
              child: SafeArea(
                child: Column(
                children: [
                  // Video Player Area
                  Container(
                    height: isMobile ? 200 : 400,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Video placeholder with clickable play button
                        InkWell(
                          onTap: () {
                            // Play video logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('جاري تشغيل الفيديو...'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Big Play Button
                                  Container(
                                    width: isMobile ? 80 : 100,
                                    height: isMobile ? 80 : 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: isMobile ? 40 : 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Lesson Title
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      selectedLesson['title'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isMobile ? 16 : 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Lesson Duration
                                  Text(
                                    'مدة الدرس: ${selectedLesson['duration']}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Back button for mobile
                        if (isMobile)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isVideoPlaying = false;
                                });
                              },
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Lesson Info and Controls
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lesson Navigation
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: TextButton.icon(
                                      onPressed: _selectedLessonIndex > 0 ? () {
                                        setState(() {
                                          _selectedLessonIndex--;
                                        });
                                      } : null,
                                      icon: Icon(Icons.arrow_forward, size: isMobile ? 14 : 16),
                                      label: FittedBox(
                                        child: Text('السابق', style: TextStyle(fontSize: isMobile ? 11 : 13)),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          // Mark lesson as completed
                                          selectedLesson['completed'] = true;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('تم إكمال الدرس بنجاح!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.check, size: isMobile ? 14 : 16),
                                      label: FittedBox(
                                        child: Text('إكمال', style: TextStyle(fontSize: isMobile ? 11 : 13)),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isMobile ? 12 : 16,
                                          vertical: isMobile ? 6 : 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: TextButton.icon(
                                      onPressed: _selectedLessonIndex < (selectedModule['lessons'] as List).length - 1 ? () {
                                        setState(() {
                                          _selectedLessonIndex++;
                                        });
                                      } : null,
                                      icon: Icon(Icons.arrow_back, size: isMobile ? 14 : 16),
                                      label: FittedBox(
                                        child: Text('التالي', style: TextStyle(fontSize: isMobile ? 11 : 13)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Lesson Title
                            Text(
                              selectedLesson['title'],
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Lesson Meta
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getLessonIcon(selectedLesson['type']),
                                      size: isMobile ? 16 : 20,
                                      color: _getLessonIconColor(selectedLesson['type']),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'نوع الدرس: ${_getLessonTypeName(selectedLesson['type'])}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: isMobile ? 12 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time, size: isMobile ? 16 : 20, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Text(
                                      'المدة: ${selectedLesson['duration']}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: isMobile ? 12 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Lesson Description
                            Text(
                              'وصف الدرس',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'هذا الدرس يغطي المفاهيم الأساسية والمتقدمة في الموضوع المطروح. ستتعلم من خلاله الأسس النظرية والتطبيقات العملية.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Resources
                            Text(
                              'المصادر والملفات',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildResourceItem('ملف PDF - المحاضرة', Icons.picture_as_pdf, Colors.red),
                            _buildResourceItem('كود المثال', Icons.code, Colors.blue),
                            _buildResourceItem('التمرين العملي', Icons.assignment, Colors.orange),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: _getCategoryColor(widget.course.category)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceItem(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري تحميل الملف...'),
                ),
              );
            },
            icon: const Icon(Icons.download, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  String _getLessonTypeName(String type) {
    switch (type) {
      case 'video':
        return 'فيديو';
      case 'quiz':
        return 'اختبار';
      case 'practice':
        return 'تدريب عملي';
      case 'project':
        return 'مشروع';
      default:
        return 'مقال';
    }
  }
}