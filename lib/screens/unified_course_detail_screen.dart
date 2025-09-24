import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_theme.dart';
import '../providers/course_provider.dart';
import '../models/course.dart';
import '../features/auth/providers/auth_provider.dart';
import 'course_content_screen.dart';

class UnifiedCourseDetailScreen extends StatefulWidget {
  final dynamic course;
  final String? courseId;

  const UnifiedCourseDetailScreen({
    super.key,
    this.course,
    this.courseId,
  }) : assert(course != null || courseId != null);

  @override
  State<UnifiedCourseDetailScreen> createState() => _UnifiedCourseDetailScreenState();
}

class _UnifiedCourseDetailScreenState extends State<UnifiedCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Course? _course;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourse();
      _trackCourseView();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourse() async {
    if (widget.course != null) {
      if (widget.course is Course) {
        _course = widget.course;
      } else {
        // Convert Map to Course if needed
        _course = Course(
          id: widget.course['id'] ?? widget.courseId ?? '',
          title: widget.course['title'] ?? '',
          titleAr: widget.course['titleAr'] ?? widget.course['title'] ?? '',
          description: widget.course['description'] ?? '',
          descriptionAr: widget.course['descriptionAr'] ?? widget.course['description'] ?? '',
          instructor: {'name': widget.course['instructorName'] ?? 'مدرب رقيم'},
          price: widget.course['price'] is String
              ? double.tryParse(widget.course['price'].replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0
              : (widget.course['price'] ?? 0).toDouble(),
          rating: widget.course['rating'] is String
              ? double.tryParse(widget.course['rating']) ?? 4.5
              : (widget.course['rating'] ?? 4.5).toDouble(),
          numberOfRatings: widget.course['numberOfRatings'] ?? 0,
          totalStudents: widget.course['totalStudents'] ?? 0,
          totalLessons: widget.course['totalLessons'] ?? widget.course['lessonsCount'] ?? 15,
          duration: Duration(hours: widget.course['duration'] is String
              ? int.tryParse(widget.course['duration'].replaceAll(RegExp(r'[^\d]'), '')) ?? 12
              : widget.course['duration'] ?? 12),
          level: widget.course['level'] ?? 'beginner',
          category: widget.course['category'],
          whatYouWillLearn: List<String>.from(widget.course['whatYouWillLearn'] ?? []),
          requirements: List<String>.from(widget.course['requirements'] ?? []),
          isEnrolled: widget.course['isEnrolled'] ?? false,
          thumbnail: widget.course['thumbnail'] ?? widget.course['thumbnailUrl'],
        );
      }
      setState(() {
        _isLoading = false;
      });
    } else if (widget.courseId != null) {
      // Try to get course from provider first
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      _course = courseProvider.getCourseById(widget.courseId!);

      if (_course == null) {
        // If course not found, load from API
        await courseProvider.loadCourses();
        _course = courseProvider.getCourseById(widget.courseId!);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _trackCourseView() async {
    // Analytics tracking disabled temporarily
  }

  Future<void> _enrollInCourse() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    final success = await courseProvider.enrollInCourse(
      _course!.id,
      authProvider.currentUser!.id,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم التسجيل في الدورة بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _course = courseProvider.getCourseById(_course!.id);
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التسجيل في الدورة: ${courseProvider.error ?? 'خطأ غير معروف'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_course == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          title: const Text('تفاصيل الدورة'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'عذراً، لم يتم العثور على الدورة',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Image
          SliverAppBar(
            expandedHeight: isMobile ? 300 : 400,
            pinned: true,
            backgroundColor: _getCategoryColor(_course!.category),
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _course!.titleAr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Course Thumbnail or Gradient
                  if (_course!.thumbnail != null && _course!.thumbnail!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: _course!.thumbnail!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getCategoryColor(_course!.category).withOpacity(0.8),
                              _getCategoryColor(_course!.category),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 100,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCategoryColor(_course!.category).withOpacity(0.8),
                            _getCategoryColor(_course!.category),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 100,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Play Button
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 80,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enrollment Status Badge
                  if (_course!.isEnrolled)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'أنت مسجل في هذه الدورة',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Quick Stats Cards
                  Container(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildStatCard(
                          Icons.star,
                          _course!.rating.toStringAsFixed(1),
                          'التقييم',
                          Colors.amber,
                        ),
                        _buildStatCard(
                          Icons.people,
                          '${_course!.totalStudents}',
                          'طالب',
                          Colors.blue,
                        ),
                        _buildStatCard(
                          Icons.video_library,
                          '${_course!.totalLessons}',
                          'درس',
                          Colors.green,
                        ),
                        _buildStatCard(
                          Icons.access_time,
                          '${_course!.duration.inHours} ساعة',
                          'المدة',
                          Colors.orange,
                        ),
                        _buildStatCard(
                          Icons.signal_cellular_alt,
                          _getLevelText(_course!.level),
                          'المستوى',
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instructor Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _getCategoryColor(_course!.category),
                          child: Text(
                            (_course!.instructor?['name'] ?? 'مدرب رقيم').isNotEmpty
                                ? (_course!.instructor?['name'] ?? 'مدرب رقيم')[0].toUpperCase()
                                : 'م',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'المدرب',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _course!.instructor?['name'] ?? 'مدرب رقيم',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_course!.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(_course!.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _course!.category!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(_course!.category),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tabs Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppColors.primaryColor,
                          indicatorWeight: 3,
                          tabs: const [
                            Tab(text: 'نظرة عامة'),
                            Tab(text: 'المحتوى'),
                            Tab(text: 'المتطلبات'),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Overview Tab
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'عن الدورة',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _course!.descriptionAr,
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.6,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Content Tab
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ماذا ستتعلم في هذه الدورة',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (_course!.whatYouWillLearn.isEmpty)
                                        Column(
                                          children: [
                                            _buildLearningItem('إتقان المفاهيم الأساسية والمتقدمة للموضوع'),
                                            _buildLearningItem('تطبيق ما تعلمته في مشاريع عملية'),
                                            _buildLearningItem('اكتساب المهارات المطلوبة في سوق العمل'),
                                            _buildLearningItem('الحصول على شهادة معتمدة عند إتمام الدورة'),
                                            _buildLearningItem('الوصول إلى مجتمع المتعلمين والخبراء'),
                                          ],
                                        )
                                      else
                                        ..._course!.whatYouWillLearn.map((item) => Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.green,
                                                width: 4,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    ],
                                  ),
                                ),
                              ),
                              // Requirements Tab
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'المتطلبات',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (_course!.requirements.isEmpty)
                                        Column(
                                          children: [
                                            _buildRequirementItem('جهاز كمبيوتر أو هاتف ذكي متصل بالإنترنت'),
                                            _buildRequirementItem('الرغبة والالتزام في التعلم'),
                                            _buildRequirementItem('تخصيص وقت كافي لمتابعة المحاضرات والتطبيق'),
                                            _buildRequirementItem('معرفة أساسية باستخدام الكمبيوتر (اختيارية)'),
                                          ],
                                        )
                                      else
                                        ..._course!.requirements.map((item) => Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.orange,
                                                width: 4,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.info_outline,
                                                color: Colors.orange,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // Modern Bottom Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<CourseProvider>(
          builder: (context, provider, child) {
            if (_course!.isEnrolled) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseContentScreen(course: _course!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'متابعة التعلم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Row(
                children: [
                  // Price Display
                  if (!_course!.isFree)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'السعر',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _course!.price.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'ريال',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  // Enroll Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _enrollInCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getCategoryColor(_course!.category),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _course!.isFree ? Icons.lock_open : Icons.shopping_cart,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _course!.isFree ? 'التسجيل المجاني' : 'التسجيل في الدورة',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: BorderSide(
            color: Colors.green,
            width: 4,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: BorderSide(
            color: Colors.orange,
            width: 4,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}