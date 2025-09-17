import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/courses_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../widgets/common/modern_search_field.dart';
import '../../../widgets/common/pill_button.dart';
import '../../../widgets/common/animated_course_card.dart';
import '../../../widgets/common/modern_course_card.dart' show ModernCourseCard;

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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Search and Filters Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
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

                const SizedBox(height: 24),

                // Filters Header
                Row(
                  children: [
                    Text(
                      'الفلاتر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        coursesProvider.filterCourses(category: 'الكل');
                      },
                      icon: Icon(Icons.clear_all, size: 18, color: Colors.grey[600]),
                      label: Text(
                        'مسح الكل',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // By Category
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'حسب الفئة:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Categories Filter - Horizontal Scrollable
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _getCategoryFilters(context).map((category) {
                      final isSelected = _isFilterSelected(category['value'], coursesProvider);
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () => _onFilterPressed(category['value'], coursesProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF4285F4) : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF4285F4) : Colors.grey[300]!,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category['label'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // By Level
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'حسب المستوى:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Level Filters
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getLevelFilters(context).map((level) {
                    final isSelected = _isFilterSelected(level['value'], coursesProvider);
                    return GestureDetector(
                      onTap: () => _onFilterPressed(level['value'], coursesProvider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4285F4) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4285F4) : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          level['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                            return AnimatedCourseCard(
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

  List<Map<String, dynamic>> _getCategoryFilters(BuildContext context) {
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
        'label': 'معالجة اللغات',
        'value': 'معالجة اللغات',
        'type': 'category'
      },
      {
        'label': 'رؤية الحاسوب',
        'value': 'رؤية الحاسوب',
        'type': 'category'
      },
      {
        'label': 'البرمجة',
        'value': 'البرمجة',
        'type': 'category'
      },
      {
        'label': 'الذكاء التوليدي',
        'value': 'الذكاء التوليدي',
        'type': 'category'
      },
      {
        'label': 'التعلم العميق',
        'value': 'التعلم العميق',
        'type': 'category'
      },
      {
        'label': 'علم البيانات',
        'value': 'علم البيانات',
        'type': 'category'
      },
      {
        'label': 'الأعمال',
        'value': 'الأعمال',
        'type': 'category'
      },
    ];
  }

  List<Map<String, dynamic>> _getLevelFilters(BuildContext context) {
    return [
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