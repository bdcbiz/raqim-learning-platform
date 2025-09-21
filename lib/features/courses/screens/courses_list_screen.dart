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
import '../../../widgets/common/raqim_app_bar.dart';

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
  bool _showFilters = false;
  String? _selectedCategory;
  String? _selectedLevel;
  String? _selectedPriceFilter;

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

  List<dynamic> _getSampleCourses() {
    // Return mock courses data with categories matching the filter options
    return [
      {
        'id': 'sample-1',
        'title': 'مقدمة في تعلم الآلة',
        'instructorName': 'د. أحمد الرشيد',
        'thumbnailUrl': 'https://picsum.photos/400/300?random=31',
        'category': 'تعلم الآلة',
        'level': 'مبتدئ',
        'price': 299.0,
        'rating': 4.8,
        'totalStudents': 1250,
        'isEnrolled': false,
      },
      {
        'id': 'sample-2',
        'title': 'أساسيات معالجة اللغة الطبيعية',
        'instructorName': 'د. سارة جونسون',
        'thumbnailUrl': 'https://picsum.photos/400/300?random=32',
        'category': 'معالجة اللغات',
        'level': 'متوسط',
        'price': 599.0,
        'rating': 4.9,
        'totalStudents': 890,
        'isEnrolled': false,
      },
      {
        'id': 'sample-3',
        'title': 'الرؤية الحاسوبية والتعلم العميق',
        'instructorName': 'أ.د. عمر حسان',
        'thumbnailUrl': 'https://picsum.photos/400/300?random=33',
        'category': 'رؤية الحاسوب',
        'level': 'متقدم',
        'price': 799.0,
        'rating': 4.7,
        'totalStudents': 650,
        'isEnrolled': false,
      },
      {
        'id': 'sample-4',
        'title': 'أسس التعلم العميق',
        'instructorName': 'د. أحمد الرشيد',
        'thumbnailUrl': 'https://picsum.photos/400/300?random=34',
        'category': 'التعلم العميق',
        'level': 'متوسط',
        'price': 0.0,
        'rating': 4.6,
        'totalStudents': 2100,
        'isEnrolled': false,
      },
      {
        'id': 'sample-5',
        'title': 'علم البيانات للمبتدئين',
        'instructorName': 'د. محمد علي',
        'thumbnailUrl': 'https://picsum.photos/400/300?random=35',
        'category': 'علم البيانات',
        'level': 'مبتدئ',
        'price': 0.0,
        'rating': 4.7,
        'totalStudents': 1800,
        'isEnrolled': false,
      },
      {
        'id': 'sample-6',
        'title': 'برمجة Python للذكاء الاصطناعي',
        'instructorName': 'م. فاطمة أحمد',
        'thumbnailUrl': 'https://picsum.photos/400/300?random=36',
        'category': 'البرمجة',
        'level': 'متقدم',
        'price': 399.0,
        'rating': 4.9,
        'totalStudents': 1500,
        'isEnrolled': false,
      },
    ];
  }
  
  String _getLocalizedCourseTitle(dynamic course, BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final courseId = course is Map ? course['id'] : course.id;
    final courseTitle = course is Map ? course['title'] : course.title;

    switch (courseId) {
      case '1':
        return localizations?.translate('mlForBeginnersTitle') ?? courseTitle;
      case '2':
        return localizations?.translate('nlpAdvancedTitle') ?? courseTitle;
      case '3':
        return localizations?.translate('computerVisionTitle') ?? courseTitle;
      default:
        return courseTitle;
    }
  }
  
  String _getLocalizedInstructorName(dynamic course, BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final instructorId = course is Map ? course['instructorId'] : course.instructorId;
    final instructorName = course is Map ? course['instructorName'] : course.instructorName;

    switch (instructorId) {
      case '1':
        return localizations?.translate('instructorAhmed') ?? instructorName;
      case '2':
        return localizations?.translate('instructorSara') ?? instructorName;
      case '3':
        return localizations?.translate('instructorKhaled') ?? instructorName;
      default:
        return instructorName;
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
    List<dynamic> displayCourses = widget.showOnlyEnrolled
        ? coursesProvider.courses.where((course) => course.isEnrolled == true).toList()
        : coursesProvider.courses.cast<dynamic>();

    // If no courses available or too few courses, show sample courses
    if ((displayCourses.isEmpty || displayCourses.length < 6) && !coursesProvider.isLoading) {
      var sampleCourses = _getSampleCourses();

      // Apply category filter to sample courses if selected
      if (_selectedCategory != null && _selectedCategory != 'all') {
        sampleCourses = sampleCourses.where((course) {
          final courseCategory = course['category'] as String?;
          return courseCategory == _selectedCategory;
        }).toList();
      }

      // Apply level filter to sample courses if selected
      if (_selectedLevel != null && _selectedLevel!.isNotEmpty) {
        sampleCourses = sampleCourses.where((course) {
          final courseLevel = course['level'] as String?;
          return courseLevel == _selectedLevel;
        }).toList();
      }

      // Apply search filter to sample courses
      if (_searchController.text.isNotEmpty) {
        final searchQuery = _searchController.text.toLowerCase();
        sampleCourses = sampleCourses.where((course) {
          final title = (course['title'] as String? ?? '').toLowerCase();
          final instructor = (course['instructorName'] as String? ?? '').toLowerCase();
          return title.contains(searchQuery) || instructor.contains(searchQuery);
        }).toList();
      }

      displayCourses = sampleCourses;
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: isWideScreen ? null : RaqimAppBar(
        title: widget.showOnlyEnrolled
            ? (AppLocalizations.of(context)?.translate('myCourses') ?? 'كورساتي')
            : (AppLocalizations.of(context)?.translate('coursesTitle') ?? 'الدورات التعليمية'),
      ),
      body: Column(
        children: [
          // Desktop Header for wide screens
          if (isWideScreen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Text(
                widget.showOnlyEnrolled
                    ? (AppLocalizations.of(context)?.translate('myCourses') ?? 'كورساتي')
                    : (AppLocalizations.of(context)?.translate('coursesTitle') ?? 'الدورات التعليمية'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),

          // Search and Filters Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar with Filter Icon
                Stack(
                  children: [
                    ModernSearchField(
                      controller: _searchController,
                      hintText: AppLocalizations.of(context)?.translate('searchCourse') ?? 'ابحث عن دورة...',
                      onChanged: (value) {
                        coursesProvider.filterCourses(searchQuery: value);
                      },
                      suffixIcon: Icons.filter_list,
                      onSuffixIconTap: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                    ),
                    // Clear button overlay when text is not empty
                    if (_searchController.text.isNotEmpty)
                      Positioned(
                        right: 50,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppColors.secondaryText,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            coursesProvider.filterCourses(searchQuery: '');
                          },
                        ),
                      ),
                  ],
                ),

                // Animated Filter Section
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _showFilters
                      ? Column(
                          children: [
                            const SizedBox(height: 20),
                            // Filter Categories Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الفلاتر',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedCategory = null;
                                      _selectedLevel = null;
                                      _selectedPriceFilter = null;
                                    });
                                    coursesProvider.filterCourses(
                                      searchQuery: _searchController.text,
                                    );
                                  },
                                  child: Text(
                                    'مسح الكل',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Filter Categories
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // By Category
                                Text(
                                  'حسب الفئة:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _getCategoryFilters(context).map((category) {
                                    final isSelected = _selectedCategory == category['value'];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = _selectedCategory == category['value']
                                              ? null
                                              : category['value'] as String?;
                                        });
                                        coursesProvider.filterCourses(
                                          searchQuery: _searchController.text,
                                          category: _selectedCategory ?? 'الكل',
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primaryColor : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          category['label'] as String,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.grey[700],
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                // By Level
                                Text(
                                  'حسب المستوى:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _getLevelFilters(context).map((level) {
                                    final isSelected = _selectedLevel == level['value'];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedLevel = _selectedLevel == level['value']
                                              ? null
                                              : level['value'] as String?;
                                        });
                                        coursesProvider.filterCourses(
                                          searchQuery: _searchController.text,
                                          level: _selectedLevel ?? '',
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primaryColor : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          level['label'] as String,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.grey[700],
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // Original filters are now hidden since we have them in the search bar icon
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

                            // Handle both Map and CourseModel objects
                            final courseId = course is Map ? course['id'] : course.id;
                            final thumbnailUrl = course is Map ? course['thumbnailUrl'] : course.thumbnailUrl;
                            final category = course is Map ? course['category'] : course.category;
                            final price = course is Map ? course['price'] : course.price;
                            final rating = course is Map ? course['rating'] : course.rating;

                            return AnimatedCourseCard(
                              title: _getLocalizedCourseTitle(course, context),
                              instructor: _getLocalizedInstructorName(course, context),
                              imageUrl: thumbnailUrl ?? '',
                              category: category ?? 'تعلم الآلة',
                              studentsCount: 500,
                              price: (price == 0 || price == 0.0) ? 'مجاني' : '${price?.toInt() ?? 0} ر.س',
                              rating: rating?.toDouble() ?? 4.5,
                              categoryColor: ModernCourseCard.getCategoryColor(category ?? 'تعلم الآلة'),
                              onTap: () {
                                Provider.of<CoursesProvider>(context, listen: false).selectCourse(courseId);
                                context.go('/course/$courseId');
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