import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/providers/courses_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/welcome_header.dart';
import '../../../widgets/common/modern_search_field.dart';
import '../../../widgets/common/pill_button.dart';
import '../../../widgets/common/modern_course_card.dart';
import '../../../screens/courses_screen.dart';
import '../../../services/tracking/interaction_tracker.dart';
import '../../../widgets/common/advertisements_carousel.dart';
import '../../../providers/course_provider.dart';
import '../../../services/auth/auth_interface.dart';

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
    // Try to get user from WebAuthService first (for web)
    final authService = Provider.of<AuthServiceInterface>(context);
    final webUser = authService.currentUser;

    // Fallback to AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final authProviderUser = authProvider.currentUser;

    // Use whichever has a user
    final user = webUser ?? authProviderUser;

    final coursesProvider = Provider.of<CoursesProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Welcome Header
              WelcomeHeader(
                userName: user?.name ?? 'المستخدم',
                userAvatarUrl: user?.photoUrl,
                onAvatarTap: () {
                  // Navigate to profile
                  context.go('/profile');
                },
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ModernSearchField(
                  controller: _searchController,
                  hintText: 'ماذا تود أن تتعلم اليوم؟',
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
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return PillButton(
                      text: category,
                      isSelected: category == _selectedCategory,
                      onPressed: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        // No need to call provider filter here, we filter locally in _buildCoursesGrid
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Popular Courses Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الكورسات الشائعة',
                      style: AppTextStyles.h2,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to courses screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CoursesScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'عرض الكل',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryColor,
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
              
              const SizedBox(height: 100), // Space for bottom navigation
          ],
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

    // If no courses at all, show sample courses
    if (allCourses.isEmpty) {
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

    // Show only first 6 courses as "popular" courses
    final popularCourses = filteredCourses.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
        crossAxisSpacing: MediaQuery.of(context).size.width > 900 ? 16 : 12,
        mainAxisSpacing: MediaQuery.of(context).size.width > 900 ? 16 : 12,
        childAspectRatio: MediaQuery.of(context).size.width > 900 ? 1.3 : 0.85,
      ),
      itemCount: popularCourses.length,
      itemBuilder: (context, index) {
        final course = popularCourses[index];
        // Use same card design as all courses screen
        return ModernCourseCard(
          title: course.title,
          instructor: course.instructorName ?? course.instructor?['name'] ?? 'مدرب معتمد',
          imageUrl: course.thumbnail ?? 'https://picsum.photos/400/300?random=${course.id}',
          category: course.category ?? 'تعلم الآلة',
          studentsCount: course.totalStudents ?? 500,
          price: course.price == 0 ? 'مجاني' : '${course.price} ريال',
          rating: course.rating ?? 4.5,
          categoryColor: ModernCourseCard.getCategoryColor(course.category ?? 'تعلم الآلة'),
          onTap: () {
            // Track course click
            _tracker.trackButtonClick('view_course', additionalData: {'courseId': course.id, 'from': 'home'});
            // Navigate to course details
            context.go('/course/${course.id}');
          },
        );
      },
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
      {
        'id': 'sample-python-101',
        'title': 'برمجة Python للذكاء الاصطناعي',
        'instructor': 'م. فاطمة أحمد',
        'image': 'https://picsum.photos/400/300?random=26',
        'lessons': 30,
        'duration': '20 ساعة',
        'price': '399 ريال',
        'rating': 4.9,
        'category': 'البرمجة',
      },
      {
        'id': 'sample-ai-gen-101',
        'title': 'الذكاء الاصطناعي التوليدي',
        'instructor': 'د. سلمى خالد',
        'image': 'https://picsum.photos/400/300?random=27',
        'lessons': 16,
        'duration': '10 ساعة',
        'price': '599 ريال',
        'rating': 4.8,
        'category': 'الذكاء التوليدي',
      },
      {
        'id': 'sample-business-101',
        'title': 'الذكاء الاصطناعي في الأعمال',
        'instructor': 'أ. حسام الدين',
        'image': 'https://picsum.photos/400/300?random=28',
        'lessons': 12,
        'duration': '8 ساعة',
        'price': '249 ريال',
        'rating': 4.5,
        'category': 'الأعمال',
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
        crossAxisSpacing: MediaQuery.of(context).size.width > 900 ? 16 : 12,
        mainAxisSpacing: MediaQuery.of(context).size.width > 900 ? 16 : 12,
        childAspectRatio: MediaQuery.of(context).size.width > 900 ? 1.3 : 0.85,
      ),
      itemCount: filteredSampleCourses.length > 6 ? 6 : filteredSampleCourses.length,
      itemBuilder: (context, index) {
        final course = filteredSampleCourses[index];
        return ModernCourseCard(
          title: course['title'] as String,
          instructor: course['instructor'] as String,
          imageUrl: course['image'] as String,
          category: course['category'] as String,
          studentsCount: 500,
          price: course['price'] as String,
          rating: course['rating'] as double,
          categoryColor: ModernCourseCard.getCategoryColor(course['category'] as String),
          onTap: () => context.go('/course/${course['id']}'),
        );
      },
    );
  }
}