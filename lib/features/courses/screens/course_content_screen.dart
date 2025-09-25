import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/courses_provider.dart';
import '../../../services/sync_service.dart';
import '../../../services/api_service.dart';
import '../../../data/models/course_model.dart' as data_models;
import '../../../widgets/common/course_chapters_list.dart';

class CourseContentScreen extends StatefulWidget {
  final String courseId;

  const CourseContentScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  data_models.CourseModel? course;
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;
  int _selectedModuleIndex = 0;
  int? _selectedLessonIndex;
  String? _selectedVideoUrl;
  bool _isLoading = true;
  bool _showVideoPlayer = false;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadCourse() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to fetch real data from API
      print('Loading course with ID: ${widget.courseId}');
      final response = await ApiService.getCourse(int.tryParse(widget.courseId) ?? 1);

      print('API Response: $response');

      if (response['success'] == true && response['data'] != null) {
        print('Course loaded successfully from API');
        final courseData = response['data'];
        print('Course data modules count: ${courseData['modules']?.length ?? 0}');

        setState(() {
          course = _parseCourseFromApi(courseData);
          _isLoading = false;
        });

        print('Parsed course modules count: ${course?.modules.length ?? 0}');
      } else {
        print('Failed to load course, using mock data');
        // Fallback to mock data
        setState(() {
          course = _createMockCourse();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading course from API: $e');
      print('Using mock data as fallback');
      // Fallback to mock data
      setState(() {
        course = _createMockCourse();
        _isLoading = false;
      });
    }
  }

  data_models.CourseModel _parseCourseFromApi(Map<String, dynamic> courseData) {
    List<data_models.CourseModule> modules = [];

    print('Parsing course data: ${courseData.keys}');

    if (courseData['modules'] != null) {
      print('Found ${courseData['modules'].length} modules');
      for (var moduleData in courseData['modules']) {
        List<data_models.Lesson> lessons = [];

        if (moduleData['lessons'] != null) {
          print('Module "${moduleData['title_ar']}" has ${moduleData['lessons'].length} lessons');
          for (var lessonData in moduleData['lessons']) {
            print('Lesson: ${lessonData['title_ar']} - Video: ${lessonData['video_url']}');
            lessons.add(
              data_models.Lesson(
                id: lessonData['id'].toString(),
                title: lessonData['title_ar'] ?? lessonData['title_en'] ?? 'درس',
                duration: Duration(seconds: lessonData['duration'] ?? 600),
                videoUrl: lessonData['video_url'],
                content: lessonData['description_ar'] ?? lessonData['content_ar'] ?? '',
              ),
            );
          }
        }

        modules.add(
          data_models.CourseModule(
            id: moduleData['id'].toString(),
            title: moduleData['title_ar'] ?? moduleData['title_en'] ?? 'وحدة',
            duration: Duration(hours: 1), // Calculate from lessons if needed
            lessons: lessons,
          ),
        );
      }
    }

    return data_models.CourseModel(
      id: courseData['id'].toString(),
      title: courseData['title_ar'] ?? courseData['title_en'] ?? 'دورة تدريبية',
      description: courseData['description_ar'] ?? courseData['description_en'] ?? '',
      thumbnailUrl: courseData['thumbnail'] ?? 'https://picsum.photos/400/225',
      instructorId: courseData['instructor_id']?.toString() ?? '1',
      instructorName: courseData['instructor']?['name'] ?? 'المدرب',
      instructorBio: courseData['instructor']?['bio'] ?? '',
      level: courseData['level'] ?? 'مبتدئ',
      category: courseData['category']?['name_ar'] ?? 'تصنيف',
      objectives: [],
      requirements: [],
      modules: modules,
      price: double.tryParse(courseData['price']?.toString() ?? '0') ?? 0,
      totalDuration: Duration(hours: courseData['duration_hours'] ?? 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  data_models.CourseModel _createMockCourse() {
    return data_models.CourseModel(
      id: widget.courseId,
      title: 'دورة البرمجة الأساسية',
      description: 'تعلم أساسيات البرمجة',
      thumbnailUrl: 'https://picsum.photos/400/225',
      instructorId: '1',
      instructorName: 'د. أحمد محمد',
      instructorBio: 'خبير في البرمجة',
      level: 'مبتدئ',
      category: 'البرمجة',
      objectives: ['تعلم البرمجة', 'فهم الخوارزميات'],
      requirements: ['لا توجد متطلبات مسبقة'],
      modules: [
        data_models.CourseModule(
          id: 'module1',
          title: 'المقدمة',
          duration: const Duration(hours: 2),
          lessons: [
            data_models.Lesson(
              id: 'lesson1',
              title: 'ما هي البرمجة؟',
              duration: const Duration(minutes: 30),
              videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              content: 'في هذا الدرس سنتعرف على مفهوم البرمجة وأساسياتها',
            ),
            data_models.Lesson(
              id: 'lesson2',
              title: 'إعداد بيئة التطوير',
              duration: const Duration(minutes: 45),
              videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
              content: 'تعلم كيفية إعداد بيئة التطوير المناسبة',
            ),
          ],
        ),
        data_models.CourseModule(
          id: 'module2',
          title: 'المتغيرات والدوال',
          duration: const Duration(hours: 3),
          lessons: [
            data_models.Lesson(
              id: 'lesson3',
              title: 'المتغيرات',
              duration: const Duration(minutes: 40),
              videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
              content: 'فهم المتغيرات وأنواعها المختلفة',
            ),
            data_models.Lesson(
              id: 'lesson4',
              title: 'الدوال',
              duration: const Duration(minutes: 50),
              videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
              content: 'تعلم إنشاء واستخدام الدوال',
            ),
          ],
        ),
      ],
      price: 299.0,
      totalDuration: const Duration(hours: 5),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _playVideo(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الفيديو غير متوفر حالياً')),
      );
      return;
    }

    setState(() {
      _isVideoLoading = true;
      _selectedVideoUrl = videoUrl;
    });

    try {
      // Dispose of previous controller
      await _videoController?.dispose();

      // Create new controller
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      // Initialize the controller
      await _videoController!.initialize();

      setState(() {
        _isVideoLoading = false;
        _showVideoPlayer = true;
      });

      // Start playing automatically
      _videoController!.play();

    } catch (e) {
      setState(() {
        _isVideoLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل الفيديو: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (course == null) {
      return const Scaffold(
        body: Center(
          child: Text('لا توجد بيانات للدورة'),
        ),
      );
    }

    // Convert modules to ChapterData format
    final chapters = _convertToChapterData();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Video Player Section
            if (_showVideoPlayer && _videoController != null)
              _buildVideoPlayer(),

            // Loading indicator for video
            if (_isVideoLoading)
              Container(
                height: 200,
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل الفيديو...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // New Course Chapters List with modern design
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CourseChaptersList(
                  courseTitle: course!.title,
                  chapters: chapters,
                  onChapterTap: (index) {
                    // Play the video for the selected lesson
                    if (index < chapters.length) {
                      _playVideo(chapters[index].videoUrl);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChapterData> _convertToChapterData() {
    List<ChapterData> chapters = [];

    for (var module in course!.modules) {
      for (var lesson in module.lessons) {
        chapters.add(
          ChapterData(
            title: lesson.title,
            subtitle: lesson.content ?? module.title,
            duration: '${lesson.duration.inMinutes} دقيقة',
            thumbnailUrl: course!.thumbnailUrl,
            videoUrl: lesson.videoUrl ?? '',
            instructorName: course!.instructorName,
            instructorImage: '',
            isLocked: false,
          ),
        );
      }
    }

    return chapters;
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null) return const SizedBox.shrink();

    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Video Player
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),

          // Video Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Play/Pause Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Video Progress
                  Expanded(
                    child: VideoProgressIndicator(
                      _videoController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFF667eea),
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Close Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showVideoPlayer = false;
                        _videoController?.pause();
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'بواسطة ${course!.instructorName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Content Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.play_lesson, color: Color(0xFF667eea)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'محتوى الدورة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${course!.modules.length} وحدة',
                    style: const TextStyle(
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Modules List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: course!.modules.length,
              itemBuilder: (context, moduleIndex) {
                final module = course!.modules[moduleIndex];
                final isExpanded = _selectedModuleIndex == moduleIndex;

                return _buildModuleItem(module, moduleIndex, isExpanded);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItem(data_models.CourseModule module, int moduleIndex, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xFF667eea) : Colors.grey.shade200,
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          // Module Header
          InkWell(
            onTap: () {
              setState(() {
                _selectedModuleIndex = isExpanded ? -1 : moduleIndex;
                _selectedLessonIndex = null;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? const Color(0xFF667eea)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${moduleIndex + 1}',
                        style: TextStyle(
                          color: isExpanded ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                          module.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isExpanded
                                ? const Color(0xFF667eea)
                                : const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${module.lessons.length} دروس • ${module.duration.inMinutes} دقيقة',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isExpanded
                        ? const Color(0xFF667eea)
                        : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Lessons List
          if (isExpanded) ...[
            const Divider(height: 1),
            ...module.lessons.asMap().entries.map((entry) {
              final lessonIndex = entry.key;
              final lesson = entry.value;
              final isSelected = _selectedLessonIndex == lessonIndex;

              return _buildLessonItem(lesson, lessonIndex, isSelected);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonItem(data_models.Lesson lesson, int lessonIndex, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLessonIndex = lessonIndex;
        });
        _playVideo(lesson.videoUrl);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667eea).withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected
                  ? const Color(0xFF667eea)
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 52), // Align with module icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: lesson.videoUrl != null
                    ? const Color(0xFF667eea).withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                lesson.videoUrl != null ? Icons.play_arrow : Icons.article,
                color: lesson.videoUrl != null
                    ? const Color(0xFF667eea)
                    : Colors.grey.shade600,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF667eea)
                          : const Color(0xFF2D3748),
                    ),
                  ),
                  if (lesson.content != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      lesson.content!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${lesson.duration.inMinutes} د',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}