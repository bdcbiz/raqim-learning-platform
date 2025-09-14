import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/courses_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../widgets/common/modern_search_field.dart';
import '../../../widgets/common/pill_button.dart';
import '../../../widgets/common/modern_course_card.dart';

class CoursesListScreen extends StatefulWidget {
  final bool showOnlyEnrolled;
  
  const CoursesListScreen({
    super.key,
    this.showOnlyEnrolled = false,
  });

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if there's a search query in the URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final searchQuery = uri.queryParameters['search'];
      if (searchQuery != null && searchQuery.isNotEmpty) {
        _searchController.text = searchQuery;
        Provider.of<CoursesProvider>(context, listen: false)
            .filterCourses(searchQuery: searchQuery);
      }
    });
  }
  
  String _getLocalizedCourseTitle(dynamic course, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (course.id) {
      case '1':
        return localizations?.translate('mlForBeginnersTitle') ?? course.title;
      case '2':
        return localizations?.translate('nlpAdvancedTitle') ?? course.title;
      case '3':
        return localizations?.translate('computerVisionTitle') ?? course.title;
      default:
        return course.title;
    }
  }
  
  String _getLocalizedInstructorName(dynamic course, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (course.instructorId) {
      case '1':
        return localizations?.translate('instructorAhmed') ?? course.instructorName;
      case '2':
        return localizations?.translate('instructorSara') ?? course.instructorName;
      case '3':
        return localizations?.translate('instructorKhaled') ?? course.instructorName;
      default:
        return course.instructorName;
    }
  }
  
  String _getLocalizedLevel(String level, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (level) {
      case 'مبتدئ':
        return localizations?.translate('beginner') ?? level;
      case 'متوسط':
        return localizations?.translate('intermediate') ?? level;
      case 'متقدم':
        return localizations?.translate('advanced') ?? level;
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesProvider = Provider.of<CoursesProvider>(context);
    final isWideScreen = MediaQuery.of(context).size.width > 900;
    
    // Filter courses based on enrollment if needed
    final displayCourses = widget.showOnlyEnrolled 
        ? coursesProvider.courses.where((course) => course.isEnrolled == true).toList()
        : coursesProvider.courses;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          widget.showOnlyEnrolled 
              ? (AppLocalizations.of(context)?.translate('myCourses') ?? 'كورساتي')
              : (AppLocalizations.of(context)?.translate('coursesTitle') ?? 'الدورات التعليمية'),
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filters Section
          Container(
            color: AppColors.primaryBackground,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                ModernSearchField(
                  controller: _searchController,
                  hintText: AppLocalizations.of(context)?.translate('searchCourse') ?? 'ابحث عن دورة...',
                  onChanged: (value) {
                    coursesProvider.filterCourses(searchQuery: value);
                  },
                  suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
                  onSuffixIconTap: () {
                    _searchController.clear();
                    coursesProvider.filterCourses(searchQuery: '');
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Filter Pills
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _getFilterCategories(context).length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = _getFilterCategories(context)[index];
                      return PillButton(
                        text: category['label'],
                        isSelected: _isFilterSelected(category['value'], coursesProvider),
                        onPressed: () => _onFilterPressed(category['value'], coursesProvider),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Courses List
          Expanded(
            child: coursesProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : coursesProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(
                              coursesProvider.error!,
                              style: AppTextStyles.body,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => coursesProvider.loadCourses(),
                              child: Text(AppLocalizations.of(context)?.translate('retry') ?? 'إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => coursesProvider.loadCourses(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWideScreen ? 3 : 2,
                            childAspectRatio: isWideScreen ? 1.3 : 0.85,  // Adjusted aspect ratio for web to fit content exactly
                            crossAxisSpacing: isWideScreen ? 16 : 12,
                            mainAxisSpacing: isWideScreen ? 16 : 12,
                          ),
                          itemCount: displayCourses.length,
                          itemBuilder: (context, index) {
                            final course = displayCourses[index];
                            return ModernCourseCard(
                              title: _getLocalizedCourseTitle(course, context),
                              instructor: _getLocalizedInstructorName(course, context),
                              imageUrl: course.thumbnailUrl,
                              category: course.category ?? 'تعلم الآلة',
                              studentsCount: 500,
                              price: course.price == 0 ? 'مجاني' : '${course.price.toInt()} ر.س',
                              rating: course.rating,
                              categoryColor: ModernCourseCard.getCategoryColor(course.category ?? 'تعلم الآلة'),
                              onTap: () {
                                Provider.of<CoursesProvider>(context, listen: false).selectCourse(course.id);
                                context.go('/course/${course.id}');
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilterCategories(BuildContext context) {
    return [
      {
        'label': AppLocalizations.of(context)?.translate('all') ?? 'الكل',
        'value': 'all',
        'type': 'category'
      },
      {
        'label': AppLocalizations.of(context)?.translate('machineLearning') ?? 'تعلم الآلة',
        'value': 'تعلم الآلة',
        'type': 'category'
      },
      {
        'label': 'معالجة اللغات', // Match mock data exactly
        'value': 'معالجة اللغات',
        'type': 'category'
      },
      {
        'label': 'رؤية الحاسوب', // Match mock data exactly
        'value': 'رؤية الحاسوب',
        'type': 'category'
      },
      {
        'label': 'البرمجة', // Add missing category from mock data
        'value': 'البرمجة',
        'type': 'category'
      },
      {
        'label': 'الذكاء التوليدي', // Add missing category from mock data
        'value': 'الذكاء التوليدي',
        'type': 'category'
      },
      {
        'label': 'التعلم العميق', // Add missing category from mock data
        'value': 'التعلم العميق',
        'type': 'category'
      },
      {
        'label': 'علم البيانات', // Add missing category from mock data
        'value': 'علم البيانات',
        'type': 'category'
      },
      {
        'label': 'الأعمال', // Add missing category from mock data
        'value': 'الأعمال',
        'type': 'category'
      },
      {
        'label': _getLocalizedLevel('مبتدئ', context),
        'value': 'مبتدئ',
        'type': 'level'
      },
      {
        'label': _getLocalizedLevel('متوسط', context),
        'value': 'متوسط',
        'type': 'level'
      },
      {
        'label': _getLocalizedLevel('متقدم', context),
        'value': 'متقدم',
        'type': 'level'
      },
    ];
  }

  bool _isFilterSelected(String value, CoursesProvider provider) {
    if (value == 'all') {
      return provider.selectedCategory == 'الكل';
    }
    return provider.selectedCategory == value || provider.selectedLevel == value;
  }

  void _onFilterPressed(String value, CoursesProvider provider) {
    if (value == 'all') {
      provider.filterCourses(category: 'الكل');
    } else if (['مبتدئ', 'متوسط', 'متقدم'].contains(value)) {
      provider.filterCourses(level: value);
    } else {
      provider.filterCourses(category: value);
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}