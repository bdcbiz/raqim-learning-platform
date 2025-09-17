import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/raqim_app_bar.dart';
import '../widgets/common/modern_button.dart';
import '../widgets/common/modern_card.dart';
import '../services/analytics/analytics_service_factory.dart';
import '../providers/course_provider.dart';
import '../models/course.dart';
import '../features/auth/providers/auth_provider.dart';

class SimpleCourseDetailScreen extends StatefulWidget {
  final String courseId;

  const SimpleCourseDetailScreen({super.key, required this.courseId});

  @override
  State<SimpleCourseDetailScreen> createState() => _SimpleCourseDetailScreenState();
}

class _SimpleCourseDetailScreenState extends State<SimpleCourseDetailScreen> {
  Course? _course;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourse();
      _trackCourseView();
    });
  }

  Future<void> _loadCourse() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // Load courses if not already loaded
    if (courseProvider.allCourses.isEmpty) {
      await courseProvider.loadCourses();
    }

    setState(() {
      _course = courseProvider.getCourseById(widget.courseId);
      _isLoading = false;
    });
  }

  Future<void> _enrollInCourse() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      // Navigate to login if not logged in
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    final success = await courseProvider.enrollInCourse(
      widget.courseId,
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
        _course = courseProvider.getCourseById(widget.courseId);
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
        appBar: RaqimAppBar(
          title: 'تفاصيل الكورس',
          backgroundColor: Colors.white,
          titleColor: AppColors.primaryColor,
          logoColor: AppColors.primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'الدورة غير موجودة',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 8),
              Text(
                'عذراً، لم نتمكن من العثور على هذه الدورة.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 24),
              ModernButton(
                text: 'العودة للصفحة الرئيسية',
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      );
    }

    final course = _course!;
    final isFree = course.price == 0;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: RaqimAppBar(
        title: 'تفاصيل الكورس',
        backgroundColor: Colors.white,
        titleColor: AppColors.primaryColor,
        logoColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image Section
            Container(
              width: double.infinity,
              height: isMobile ? 250 : 400,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://picsum.photos/400/300?random=${course.id}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white30),
                    ),
                  ),
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title
                  Text(
                    course.titleAr,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Course Stats Row
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EAFF)),
                    ),
                    child: isMobile
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildStatItem(Icons.star, '${course.rating}', 'تقييم')),
                                  Expanded(child: _buildStatItem(Icons.people, '${course.totalStudents}', 'طالب')),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildStatItem(Icons.access_time, '${course.duration.inHours}', 'ساعة'),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(Icons.star, '${course.rating}', 'تقييم'),
                              _buildStatItem(Icons.people, '${course.totalStudents}', 'طالب'),
                              _buildStatItem(Icons.access_time, '${course.duration.inHours}', 'ساعة'),
                            ],
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Instructor Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EAFF)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryColor,
                          child: Text(
                            course.instructorName.isNotEmpty ? course.instructorName[0] : 'م',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المدرب',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course.instructorName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'مدرب معتمد',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (course.isEnrolled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'مسجل',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description Section
                  _buildSection(
                    'عن الدورة',
                    Icons.description,
                    course.descriptionAr,
                  ),

                  const SizedBox(height: 24),

                  // Learning Objectives Section
                  if (course.whatYouWillLearn.isNotEmpty)
                    _buildListSection(
                      'ماذا ستتعلم',
                      Icons.checklist,
                      course.whatYouWillLearn,
                      Icons.check_circle,
                      Colors.green,
                    ),

                  const SizedBox(height: 24),

                  // Requirements Section
                  if (course.requirements.isNotEmpty)
                    _buildListSection(
                      'المتطلبات',
                      Icons.format_list_bulleted,
                      course.requirements,
                      Icons.arrow_forward_ios,
                      AppColors.primaryColor,
                    ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom CTA Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: course.isEnrolled
              ? Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/course/${widget.courseId}/content');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'متابعة التعلم',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isFree ? 'مجاني' : '${course.price} ريال',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isFree ? Colors.green : AppColors.primaryColor,
                          ),
                        ),
                        Text(
                          'شامل جميع المميزات',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (isFree) {
                            _enrollInCourse();
                          } else {
                            // For paid courses, navigate to payment page
                            context.go('/payment', extra: {
                              'courseId': widget.courseId,
                              'courseName': course.titleAr,
                              'amount': course.price,
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isFree ? 'سجل الآن مجاناً' : 'اشترِ الآن',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, IconData titleIcon, List<String> items, IconData itemIcon, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  titleIcon,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      itemIcon,
                      color: iconColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _trackCourseView() async {
    final analytics = AnalyticsServiceFactory.instance;

    await analytics.setCurrentScreen(
      screenName: 'course_detail',
      screenClass: 'SimpleCourseDetailScreen',
    );

    if (_course != null) {
      await analytics.logCourseView(
        widget.courseId,
        _course!.titleAr,
      );
    }
  }
}