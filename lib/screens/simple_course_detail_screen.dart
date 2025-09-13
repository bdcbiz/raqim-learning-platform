import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/modern_button.dart';
import '../widgets/common/modern_card.dart';
import '../services/analytics/analytics_service_factory.dart';

class SimpleCourseDetailScreen extends StatefulWidget {
  final String courseId;

  const SimpleCourseDetailScreen({super.key, required this.courseId});

  @override
  State<SimpleCourseDetailScreen> createState() => _SimpleCourseDetailScreenState();
}

class _SimpleCourseDetailScreenState extends State<SimpleCourseDetailScreen> {

  Map<String, dynamic> _getCourseData() {
    // Sample courses data matching the home screen
    final courses = {
      'sample-ml-101': {
        'title': 'مقدمة في تعلم الآلة',
        'instructor': 'د. أحمد الرشيد',
        'image': 'https://placehold.co/400x300/3B82F6/FFFFFF?text=ML+Course',
        'lessons': 15,
        'duration': '8 ساعة',
        'price': '299 ريال',
        'rating': 4.8,
        'students': 500,
        'description': 'تعلم أساسيات تعلم الآلة وكيفية بناء نماذج ذكية باستخدام Python وTensorFlow. هذا الكورس مصمم للمبتدئين الذين يريدون دخول عالم الذكاء الاصطناعي.',
        'objectives': [
          'فهم أساسيات تعلم الآلة والذكاء الاصطناعي',
          'بناء نماذج تصنيف وتنبؤ بسيطة',
          'استخدام مكتبات Python للتعلم الآلي',
          'تطبيق الخوارزميات على مشاريع حقيقية',
        ],
        'requirements': [
          'معرفة أساسية بالبرمجة',
          'فهم أساسيات الرياضيات والإحصاء',
          'جهاز كمبيوتر مع Python مثبت',
        ],
      },
      'sample-nlp-101': {
        'title': 'أساسيات معالجة اللغة الطبيعية',
        'instructor': 'د. سارة جونسون',
        'image': 'https://placehold.co/400x300/EF4444/FFFFFF?text=NLP+Course',
        'lessons': 20,
        'duration': '12 ساعة',
        'price': '599 ريال',
        'rating': 4.9,
        'students': 450,
        'description': 'اكتشف عالم معالجة اللغة الطبيعية وتعلم كيفية بناء تطبيقات تفهم وتحلل النصوص العربية والإنجليزية.',
        'objectives': [
          'فهم أساسيات معالجة اللغة الطبيعية',
          'بناء نماذج تحليل المشاعر',
          'تطوير روبوتات دردشة ذكية',
          'معالجة النصوص العربية',
        ],
        'requirements': [
          'معرفة بلغة Python',
          'فهم أساسيات تعلم الآلة',
          'خبرة في التعامل مع البيانات',
        ],
      },
      'sample-cv-101': {
        'title': 'الرؤية الحاسوبية والتعلم العميق',
        'instructor': 'أ.د. عمر حسان',
        'image': 'https://placehold.co/400x300/10B981/FFFFFF?text=CV+Course',
        'lessons': 25,
        'duration': '15 ساعة',
        'price': '799 ريال',
        'rating': 4.7,
        'students': 350,
        'description': 'تعلم كيفية بناء أنظمة رؤية حاسوبية متقدمة باستخدام التعلم العميق والشبكات العصبية.',
        'objectives': [
          'فهم أساسيات الرؤية الحاسوبية',
          'بناء نماذج كشف الأجسام',
          'تطوير أنظمة التعرف على الوجوه',
          'معالجة وتحليل الصور',
        ],
        'requirements': [
          'خبرة في Python',
          'معرفة بأساسيات التعلم العميق',
          'جهاز بمعالج رسومي GPU (مستحسن)',
        ],
      },
      'sample-dl-101': {
        'title': 'أسس التعلم العميق',
        'instructor': 'د. أحمد الرشيد',
        'image': 'https://placehold.co/400x300/8B5CF6/FFFFFF?text=DL+Course',
        'lessons': 18,
        'duration': '10 ساعة',
        'price': 'مجاني',
        'rating': 4.6,
        'students': 800,
        'description': 'دورة مجانية شاملة في التعلم العميق والشبكات العصبية الاصطناعية.',
        'objectives': [
          'فهم الشبكات العصبية',
          'بناء نماذج التعلم العميق',
          'استخدام TensorFlow وKeras',
          'تطبيقات عملية في مجالات مختلفة',
        ],
        'requirements': [
          'معرفة بتعلم الآلة',
          'خبرة في البرمجة',
          'فهم الجبر الخطي',
        ],
      },
    };

    // Return the specific course data or a default "course not found" message
    if (courses.containsKey(widget.courseId)) {
      return courses[widget.courseId]!;
    }

    // If course not found, return a placeholder
    return {
      'title': 'الدورة غير موجودة',
      'instructor': 'غير متاح',
      'image': 'https://placehold.co/400x300/94A3B8/FFFFFF?text=Course+Not+Found',
      'lessons': 0,
      'duration': '0 ساعة',
      'price': 'غير متاح',
      'rating': 0.0,
      'students': 0,
      'description': 'عذراً، لم نتمكن من العثور على هذه الدورة. يرجى العودة إلى الصفحة الرئيسية واختيار دورة أخرى.',
      'objectives': [],
      'requirements': [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final course = _getCourseData();
    final isFree = course['price'] == 'مجاني';

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar with Course Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    course['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.inputBackground,
                        child: const Icon(Icons.image, size: 64),
                      );
                    },
                  ),
                  // Gradient overlay
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
                ],
              ),
            ),
          ),

          // Course Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title
                  Text(
                    course['title'],
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 8),

                  // Instructor Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.inputBackground,
                        child: Icon(Icons.person, color: AppColors.secondaryText),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        course['instructor'],
                        style: AppTextStyles.cardTitle,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Course Stats
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.star,
                        '${course['rating']}',
                        '',
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        Icons.people,
                        '${course['students']}',
                        'طالب',
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        Icons.schedule,
                        course['duration'],
                        '',
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        Icons.video_library,
                        '${course['lessons']}',
                        'درس',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'وصف الكورس',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 12),
                  ModernCard(
                    margin: EdgeInsets.zero,
                    child: Text(
                      course['description'],
                      style: AppTextStyles.body,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Learning Objectives
                  Text(
                    'أهداف التعلم',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 12),
                  ModernCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: (course['objectives'] as List).map((objective) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  objective,
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Requirements
                  Text(
                    'المتطلبات',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 12),
                  ModernCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: (course['requirements'] as List).map((requirement) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  requirement,
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom CTA Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 12,
              color: AppColors.shadowColor,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    course['price'],
                    style: AppTextStyles.h2.copyWith(
                      color: isFree ? AppColors.success : AppColors.primaryColor,
                    ),
                  ),
                  Text(
                    '${course['students']} طالب مسجل',
                    style: AppTextStyles.small,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ModernButton(
                text: isFree ? 'سجل الآن مجاناً' : 'اشترِ الآن',
                onPressed: () {
                  if (isFree) {
                    // For free courses, show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم التسجيل في الدورة بنجاح!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // For paid courses, navigate to payment page
                    final priceString = course['price'] as String;
                    final priceValue = double.tryParse(priceString.replaceAll('ريال', '').trim()) ?? 0.0;

                    context.go('/payment', extra: {
                      'courseId': widget.courseId,
                      'courseName': course['title'],
                      'amount': priceValue,
                    });
                  }
                },
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.secondaryText,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTextStyles.small,
          ),
        ],
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackCourseView();
    });
  }

  Future<void> _trackCourseView() async {
    final analytics = AnalyticsServiceFactory.instance;
    final course = _getCourseData();

    await analytics.setCurrentScreen(
      screenName: 'course_detail',
      screenClass: 'SimpleCourseDetailScreen',
    );

    await analytics.logCourseView(
      widget.courseId,
      course['title'] ?? 'Unknown Course',
    );
  }
}