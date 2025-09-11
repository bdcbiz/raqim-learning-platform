import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/providers/courses_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/welcome_header.dart';
import '../../../widgets/common/modern_search_field.dart';
import '../../../widgets/common/pill_button.dart';
import '../../../widgets/common/course_card.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'تعلم الآلة';

  final List<String> _categories = [
    'تعلم الآلة',
    'معالجة اللغة الطبيعية', 
    'الرؤية الحاسوبية',
    'التعلم العميق',
    'علوم البيانات'
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
                    // Handle search
                  },
                  onTap: () {
                    // Navigate to search
                    context.go('/courses');
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Category Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
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
                        },
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
                  children: [
                    Text(
                      'الكورسات الشائعة',
                      style: AppTextStyles.h2,
                    ),
                    TextButton(
                      onPressed: () => context.go('/courses'),
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
    if (courses.isEmpty) {
      // Show sample courses
      return _buildSampleCoursesGrid();
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
      itemCount: courses.length > 6 ? 6 : courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return CourseCard(
          title: course.title,
          instructor: course.instructorName ?? 'University of London',
          imageUrl: course.thumbnailUrl,
          lessonsCount: course.lessons?.length ?? 12,
          duration: '${course.duration ?? 8} ساعات',
          price: course.price == 0 ? 'مجاني' : '${course.price} ريال',
          rating: course.rating,
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
        'image': 'https://placehold.co/400x300/3B82F6/FFFFFF?text=ML+Course',
        'lessons': 15,
        'duration': '8 ساعة',
        'price': '299 ريال',
        'rating': 4.8,
      },
      {
        'id': 'sample-nlp-101',
        'title': 'أساسيات معالجة اللغة الطبيعية',
        'instructor': 'د. سارة جونسون',
        'image': 'https://placehold.co/400x300/EF4444/FFFFFF?text=NLP+Course',
        'lessons': 20,
        'duration': '12 ساعة',
        'price': '599 ريال',
        'rating': 4.9,
      },
      {
        'id': 'sample-cv-101',
        'title': 'الرؤية الحاسوبية والتعلم العميق',
        'instructor': 'أ.د. عمر حسان',
        'image': 'https://placehold.co/400x300/10B981/FFFFFF?text=CV+Course',
        'lessons': 25,
        'duration': '15 ساعة',
        'price': '799 ريال',
        'rating': 4.7,
      },
      {
        'id': 'sample-dl-101',
        'title': 'أسس التعلم العميق',
        'instructor': 'د. أحمد الرشيد',
        'image': 'https://placehold.co/400x300/8B5CF6/FFFFFF?text=DL+Course',
        'lessons': 18,
        'duration': '10 ساعة',
        'price': 'مجاني',
        'rating': 4.6,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: sampleCourses.length,
      itemBuilder: (context, index) {
        final course = sampleCourses[index];
        return CourseCard(
          title: course['title'] as String,
          instructor: course['instructor'] as String,
          imageUrl: course['image'] as String,
          lessonsCount: course['lessons'] as int,
          duration: course['duration'] as String,
          price: course['price'] as String,
          rating: course['rating'] as double,
          onTap: () => context.go('/course/${course['id']}'),
        );
      },
    );
  }
}