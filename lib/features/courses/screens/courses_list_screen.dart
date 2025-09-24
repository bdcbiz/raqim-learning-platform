import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/courses_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../widgets/common/modern_search_field.dart';
import '../../../widgets/common/pill_button.dart';
import '../../../widgets/common/unified_course_card.dart';
import '../../../widgets/common/unified_filter_section.dart';

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

    // Apply filters to real courses data
    if (displayCourses.isNotEmpty) {
      // Apply category filter
      if (_selectedCategory != null && _selectedCategory != 'all') {
        displayCourses = displayCourses.where((course) {
          final courseCategory = course is Map ? course['category'] : course.category;
          return courseCategory == _selectedCategory;
        }).toList();
      }

      // Apply level filter
      if (_selectedLevel != null && _selectedLevel!.isNotEmpty) {
        displayCourses = displayCourses.where((course) {
          final courseLevel = course is Map ? course['level'] : course.level;
          return courseLevel == _selectedLevel;
        }).toList();
      }

      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final searchQuery = _searchController.text.toLowerCase();
        displayCourses = displayCourses.where((course) {
          final title = course is Map
              ? (course['title'] as String? ?? '').toLowerCase()
              : course.titleAr.toLowerCase();
          final instructor = course is Map
              ? (course['instructorName'] as String? ?? '').toLowerCase()
              : course.instructorName.toLowerCase();
          return title.contains(searchQuery) || instructor.contains(searchQuery);
        }).toList();
      }
    }

    // Fallback to sample courses only if no real courses available
    if (displayCourses.isEmpty && !coursesProvider.isLoading) {
      displayCourses = _getSampleCourses();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: !kIsWeb,
        leading: kIsWeb ? null : Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/images/raqimLogo.svg',
            height: 32,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: kIsWeb ? Text(
          'قائمة الدورات',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ) : Center(
          child: Text(
            'قائمة الدورات',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.primaryBackground,
      body: GestureDetector(
        onTap: () {
          if (_showFilters) {
            setState(() {
              _showFilters = false;
            });
          }
        },
        child: Stack(
          children: [
            // Main content
            Column(
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
                            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: displayCourses.length,
                          itemBuilder: (context, index) {
                            final course = displayCourses[index];
                            final courseId = course is Map ? course['id'] : course.id;

                            return UnifiedCourseCard(
                              course: course,
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

            // Filter overlay
            if (_showFilters)
              Positioned(
                top: 150, // Position below search bar
                left: 16,
                right: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: UnifiedFilterSection(
                      isVisible: true,
                      filters: const [
                        // Categories
                        FilterChipData(label: 'جميع الفئات', value: '', type: FilterType.category),
                        FilterChipData(label: 'تعلم الآلة', value: 'تعلم الآلة', type: FilterType.category),
                        FilterChipData(label: 'معالجة اللغات', value: 'معالجة اللغات', type: FilterType.category),
                        FilterChipData(label: 'رؤية الحاسوب', value: 'رؤية الحاسوب', type: FilterType.category),
                        FilterChipData(label: 'التعلم العميق', value: 'التعلم العميق', type: FilterType.category),
                        FilterChipData(label: 'Python', value: 'Python', type: FilterType.category),
                        FilterChipData(label: 'علم البيانات', value: 'علم البيانات', type: FilterType.category),
                        FilterChipData(label: 'البرمجة', value: 'البرمجة', type: FilterType.category),
                        FilterChipData(label: 'الذكاء الاصطناعي', value: 'الذكاء الاصطناعي', type: FilterType.category),

                        // Levels
                        FilterChipData(label: 'جميع المستويات', value: '', type: FilterType.level),
                        FilterChipData(label: 'مبتدئ', value: 'مبتدئ', type: FilterType.level),
                        FilterChipData(label: 'متوسط', value: 'متوسط', type: FilterType.level),
                        FilterChipData(label: 'متقدم', value: 'متقدم', type: FilterType.level),
                      ],
                      selectedCategory: _selectedCategory,
                      selectedLevel: _selectedLevel ?? '',
                      onCategoryChanged: (value) {
                        setState(() {
                          _selectedCategory = value == '' ? null : value;
                        });
                      },
                      onLevelChanged: (value) {
                        setState(() {
                          _selectedLevel = value == '' ? null : value;
                        });
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}