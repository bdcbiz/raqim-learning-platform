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

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'الكل';

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
      context.read<CoursesProvider>().loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final coursesProvider = Provider.of<CoursesProvider>(context);

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
                    // Navigate to courses with search query when user starts typing
                    if (value.trim().isNotEmpty) {
                      context.go('/courses?search=${Uri.encodeComponent(value.trim())}');
                    }
                  },
                  onTap: () {
                    // Navigate to all courses screen (dashboard subroute)
                    context.go('/courses');
                  },
                ),
              ),
              
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
              
              // Course Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCoursesGrid(coursesProvider.courses),
              ),
              
              const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesGrid(List courses) {
    // Filter courses based on selected category
    final filteredCourses = _selectedCategory == 'الكل' 
        ? courses 
        : courses.where((course) => course.category == _selectedCategory).toList();
    
    if (filteredCourses.isEmpty && courses.isEmpty) {
      // Show sample courses if no courses at all
      return _buildSampleCoursesGrid();
    }
    
    if (filteredCourses.isEmpty) {
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: filteredCourses.length > 6 ? 6 : filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        // Handle totalDuration which is a Duration object
        final durationHours = course.totalDuration?.inHours ?? 8;
        return ModernCourseCard(
          title: course.title,
          instructor: course.instructorName ?? 'University of London',
          imageUrl: course.thumbnailUrl,
          category: course.category ?? 'تعلم الآلة',
          studentsCount: 500,
          price: course.price == 0 ? 'مجاني' : '${course.price} ريال',
          rating: course.rating ?? 4.5,
          categoryColor: ModernCourseCard.getCategoryColor(course.category ?? 'تعلم الآلة'),
          onTap: () => context.go('/course/${course.id}'),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68,
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