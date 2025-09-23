import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/providers/courses_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/responsive_theme.dart';
import '../../../widgets/common/welcome_header.dart';
import '../../../widgets/common/modern_search_field.dart';
import '../../../widgets/common/pill_button.dart';
import '../../../widgets/common/job_card.dart';
import '../../../models/job_model.dart' as JobModels;
import '../../../widgets/common/animated_course_card.dart';
import '../../../widgets/common/modern_course_card.dart' show ModernCourseCard;
import '../../courses/screens/courses_list_screen.dart';
import '../../../services/tracking/interaction_tracker.dart';
import '../../../widgets/common/advertisements_carousel.dart';
import '../../../providers/course_provider.dart';
import '../../../services/auth/auth_interface.dart';
import '../../jobs/screens/jobs_list_screen.dart';


class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  final InteractionTracker _tracker = InteractionTracker();

  final List<String> _categories = [
    'الكل',
    'تعلم الآلة',
    'معالجة اللغات',
    'رؤية الحاسوب',
    'التعلم العميق',
    'علم البيانات',
    'البرمجة',
    'الذكاء التوليدي',
    'الأعمال'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load courses from both providers
      context.read<CoursesProvider>().loadCourses();
      context.read<CourseProvider>().loadCourses();
      // Track home page view
      _tracker.trackPageView('home');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        leading: kIsWeb ? null : null,
        title: kIsWeb ? Text(
          'الرئيسية',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ) : Row(
          children: [
            SvgPicture.asset(
              'assets/images/raqimLogo.svg',
              height: 32,
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'الرئيسية',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32), // لموازنة عرض اللوجو
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        bottom: false,
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header - Reactive to auth changes
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  // Try to get user from WebAuthService first (for web)
                  final authService = Provider.of<AuthServiceInterface>(context, listen: false);
                  final webUser = authService.currentUser;

                  // Use whichever has a user, prioritizing the one with avatar
                  final user = webUser ?? authProvider.currentUser;

                  return WelcomeHeader(
                    userName: user?.name ?? 'المستخدم',
                    userAvatarUrl: user?.photoUrl,
                    onAvatarTap: () {
                      // Navigate to profile
                      context.go('/profile');
                    },
                  );
                },
              ),

              // Temporary Admin Access Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => context.go('/admin'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '🚀 إدارة النظام - اختبار ربط البيانات',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ModernSearchField(
                  controller: _searchController,
                  hintText: 'ماذا تود أن تتعلم اليوم؟',
                  onTap: () {
                    // Navigate to courses screen with search
                    context.go('/courses${_searchController.text.isNotEmpty ? "?search=${Uri.encodeComponent(_searchController.text)}" : ""}');
                  },
                  onChanged: (value) {
                    // Filter courses on the home screen as user types
                    setState(() {
                      _searchQuery = value.trim();
                    });
                    if (_searchQuery.isNotEmpty) {
                      _tracker.trackSearch(_searchQuery);
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 24),

              // Advertisements Carousel
              const AdvertisementCarousel(),

              const SizedBox(height: 24),

              // Category Pills
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Scrollbar(
                  thumbVisibility: false,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return Container(
                        constraints: const BoxConstraints(minWidth: 60),
                        child: PillButton(
                          text: category,
                          isSelected: category == _selectedCategory,
                          onPressed: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            // No need to call provider filter here, we filter locally in _buildCoursesGrid
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Popular Courses Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'الكورسات الشائعة',
                      style: ResponsiveAppTextStyles.h3(context),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to all courses screen
                        context.go('/courses');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'عرض الكل',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Course Grid - Use CourseProvider for better data
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCoursesGrid(courseProvider),
              ),

              const SizedBox(height: 32),

              // Job Offers Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'فرص العمل',
                      style: ResponsiveAppTextStyles.h3(context),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JobsListScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'عرض الكل',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Job Offers List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildJobOffers(),
              ),

              const SizedBox(height: 20), // Bottom padding already added in ScrollView
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesGrid(CourseProvider provider) {
    // Check if loading
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get all courses
    final allCourses = provider.allCourses;

    // Filter courses based on selected category and search query
    var filteredCourses = _selectedCategory == 'الكل'
        ? allCourses
        : allCourses.where((course) {
            // Check both category and categories fields
            if (course.categories != null && course.categories!.isNotEmpty) {
              return course.categories!.contains(_selectedCategory);
            }
            return course.category == _selectedCategory;
          }).toList();

    // Apply search filter if there's a search query
    if (_searchQuery.isNotEmpty) {
      filteredCourses = filteredCourses.where((course) {
        final query = _searchQuery.toLowerCase();
        // Get instructor name from Map if it exists
        final instructorName = course.instructor != null && course.instructor is Map
            ? ((course.instructor as Map)['name'] ?? '').toString()
            : '';
        return course.title.toLowerCase().contains(query) ||
               course.description.toLowerCase().contains(query) ||
               instructorName.toLowerCase().contains(query);
      }).toList();
    }

    // If no courses at all or too few courses, show sample courses
    if (allCourses.isEmpty || allCourses.length < 6) {
      return _buildSampleCoursesGrid();
    }

    // If filtered category has no courses
    if (filteredCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد دورات في فئة "$_selectedCategory"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show only first 6 courses as "popular" courses (to prevent too many showing then disappearing)
    final popularCourses = filteredCourses.take(6).toList();

    // Horizontal scrolling list with larger cards (same as sample courses)
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Container(
      height: isMobile ? 290 : isTablet ? 320 : 310,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 16),
        itemCount: popularCourses.length,
        itemBuilder: (context, index) {
          final course = popularCourses[index];
          return Container(
            width: isMobile ? screenWidth * 0.65 : isTablet ? 280 : 300,
            margin: EdgeInsets.only(
              left: index == popularCourses.length - 1 ? 16 : 16,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedCourseCard(
                title: course.title,
                instructor: course.instructorName,
                imageUrl: course.thumbnail ?? 'https://picsum.photos/400/300?random=${course.id}',
                category: course.category,
                studentsCount: course.totalStudents,
                price: course.price == 0 ? 'مجاني' : '${course.price} ريال',
                rating: course.rating,
                categoryColor: ModernCourseCard.getCategoryColor(course.category),
                onTap: () {
                // Track course click
                _tracker.trackButtonClick('view_course', additionalData: {'courseId': course.id, 'from': 'home'});
                // Navigate to course details
                context.go('/course/${course.id}');
              },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSampleCoursesGrid() {
    final sampleCourses = [
      {
        'id': 'sample-ml-101',
        'title': 'مقدمة في تعلم الآلة',
        'instructor': 'د. أحمد الرشيد',
        'image': 'https://picsum.photos/400/300?random=21',
        'lessons': 15,
        'duration': '8 ساعة',
        'price': '299 ريال',
        'rating': 4.8,
        'category': 'تعلم الآلة',
      },
      {
        'id': 'sample-nlp-101',
        'title': 'أساسيات معالجة اللغة الطبيعية',
        'instructor': 'د. سارة جونسون',
        'image': 'https://picsum.photos/400/300?random=22',
        'lessons': 20,
        'duration': '12 ساعة',
        'price': '599 ريال',
        'rating': 4.9,
        'category': 'معالجة اللغات',
      },
      {
        'id': 'sample-cv-101',
        'title': 'الرؤية الحاسوبية والتعلم العميق',
        'instructor': 'أ.د. عمر حسان',
        'image': 'https://picsum.photos/400/300?random=23',
        'lessons': 25,
        'duration': '15 ساعة',
        'price': '799 ريال',
        'rating': 4.7,
        'category': 'رؤية الحاسوب',
      },
      {
        'id': 'sample-dl-101',
        'title': 'أسس التعلم العميق',
        'instructor': 'د. أحمد الرشيد',
        'image': 'https://picsum.photos/400/300?random=24',
        'lessons': 18,
        'duration': '10 ساعة',
        'price': 'مجاني',
        'rating': 4.6,
        'category': 'التعلم العميق',
      },
      {
        'id': 'sample-ds-101',
        'title': 'علم البيانات للمبتدئين',
        'instructor': 'د. محمد علي',
        'image': 'https://picsum.photos/400/300?random=25',
        'lessons': 22,
        'duration': '14 ساعة',
        'price': 'مجاني',
        'rating': 4.7,
        'category': 'علم البيانات',
      },
    ];

    // Filter sample courses based on selected category
    final filteredSampleCourses = _selectedCategory == 'الكل'
        ? sampleCourses
        : sampleCourses.where((course) => course['category'] == _selectedCategory).toList();
    
    if (filteredSampleCourses.isEmpty) {
      // Show empty state for filtered category
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد دورات في فئة "$_selectedCategory"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Horizontal scrolling list with larger cards
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Container(
      height: isMobile ? 290 : isTablet ? 320 : 310,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: filteredSampleCourses.length,
        itemBuilder: (context, index) {
          final course = filteredSampleCourses[index];
          return Container(
            width: isMobile ? screenWidth * 0.65 : isTablet ? 280 : 300,
            margin: EdgeInsets.only(
              right: index == filteredSampleCourses.length - 1 ? 16 : 16,
            ),
            child: AnimatedCourseCard(
              title: course['title'] as String,
              instructor: course['instructor'] as String,
              imageUrl: course['image'] as String,
              category: course['category'] as String,
              studentsCount: 500,
              price: course['price'] as String,
              rating: course['rating'] as double,
              categoryColor: ModernCourseCard.getCategoryColor(course['category'] as String),
              onTap: () => context.go('/course/${course['id']}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobOffers() {
    // Sample job offers data
    final sampleJobs = [
      JobModels.JobOffer(
        id: 'job-1',
        title: 'مطور Flutter - الرياض',
        company: 'شركة التقنية المتقدمة',
        companyLogo: 'https://picsum.photos/100/100?random=101',
        location: 'الرياض، السعودية',
        jobType: 'دوام كامل',
        experience: 'مستوى متوسط',
        salary: '8,000 - 12,000 ر.س',
        skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
        description: 'نبحث عن مطور Flutter محترف للانضمام إلى فريقنا التقني المتميز. ستعمل على تطوير تطبيقات جوالة متطورة وتحسين الأداء والتجربة.',
        requirements: ['خبرة 3+ سنوات في Flutter', 'معرفة قوية بـ Dart', 'خبرة في REST APIs', 'Git و CI/CD'],
        benefits: ['تأمين صحي شامل', 'مكافآت سنوية', 'بيئة عمل مرنة', 'تطوير مهني مستمر'],
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        isUrgent: true,
        contactEmail: 'jobs@techcompany.sa',
      ),
      JobModels.JobOffer(
        id: 'job-2',
        title: 'مهندس ذكاء اصطناعي',
        company: 'مختبرات الابتكار',
        companyLogo: 'https://picsum.photos/100/100?random=102',
        location: 'جدة، السعودية',
        jobType: 'عن بُعد',
        experience: 'مستوى عالي',
        salary: '15,000 - 20,000 ر.س',
        skills: ['Python', 'TensorFlow', 'Machine Learning', 'NLP'],
        description: 'فرصة مميزة للعمل على مشاريع الذكاء الاصطناعي المتطورة. ستقوم بتطوير نماذج تعلم الآلة وتحليل البيانات الضخمة.',
        requirements: ['ماجستير في علوم الحاسوب أو ما يعادلها', 'خبرة 5+ سنوات في AI/ML', 'Python و TensorFlow/PyTorch', 'معرفة بـ NLP والرؤية الحاسوبية'],
        benefits: ['راتب تنافسي مميز', 'بودجت للمؤتمرات والتدريب', 'عمل مع فريق عالمي', 'مشاريع بحثية متطورة'],
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        contactEmail: 'hr@innovationlabs.sa',
      ),
      JobModels.JobOffer(
        id: 'job-3',
        title: 'محلل بيانات',
        company: 'شركة البيانات الذكية',
        companyLogo: 'https://picsum.photos/100/100?random=103',
        location: 'الدمام، السعودية',
        jobType: 'دوام جزئي',
        experience: 'مبتدئ',
        salary: '5,000 - 7,000 ر.س',
        skills: ['Python', 'SQL', 'Excel', 'Power BI'],
        description: 'ابدأ مسيرتك المهنية في مجال تحليل البيانات معنا. ستعمل على تحليل البيانات وإنشاء التقارير والرؤى التحليلية للشركة.',
        requirements: ['شهادة جامعية في الإحصاء أو الحاسوب', 'معرفة أساسية بـ Python و SQL', 'خبرة في Excel وPower BI', 'مهارات تحليلية قوية'],
        benefits: ['بيئة تعلم مثالية للمبتدئين', 'تدريب مكثف', 'فرص نمو وترقية', 'مرونة في أوقات العمل'],
        postedDate: DateTime.now().subtract(const Duration(hours: 6)),
        contactEmail: 'careers@smartdata.sa',
      ),
    ];

    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      // Mobile: Use horizontal scrolling ListView
      return SizedBox(
        height: 400, // Further increased height to prevent overflow
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8), // Reduced padding for job cards
          itemCount: sampleJobs.length,
          itemBuilder: (context, index) {
            final job = sampleJobs[index];
            return Container(
              width: screenWidth * 0.80, // Reduced from 85% to 80% to prevent right overflow
              margin: EdgeInsets.only(
                right: index == sampleJobs.length - 1 ? 0 : 12, // Fixed margin direction for RTL
              ),
              child: JobCard(
              job: job,
              showDetailedInfo: false,
              onTap: () {
                _tracker.trackButtonClick('view_job', additionalData: {
                  'jobId': job.id,
                  'company': job.company,
                  'from': 'home'
                });
                _showJobDetailsDialog(context, job);
              },
            ),
            );
          },
        ),
      );
    } else {
      // Desktop/Tablet: Use column layout with proper constraints
      return Column(
        children: sampleJobs.map((job) {
          return ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800, // Limit maximum width
            ),
            child: JobCard(
              job: job,
              showDetailedInfo: false,
              onTap: () {
                _tracker.trackButtonClick('view_job', additionalData: {
                  'jobId': job.id,
                  'company': job.company,
                  'from': 'home'
                });
                _showJobDetailsDialog(context, job);
              },
            ),
          );
        }).toList(),
      );
    }
  }

  void _showJobDetailsDialog(BuildContext context, JobModels.JobOffer job) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenWidth * 0.95 : 600,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                JobCard(
                  job: job,
                  showDetailedInfo: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    _showApplicationSuccessSnackBar(context);
                  }, // Apply action when clicking on job card
                  onClose: () {
                    Navigator.of(context).pop();
                  }, // Close dialog when clicking close button
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showApplicationSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تم إرسال طلبك بنجاح!',
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }


}