import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/courses_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
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

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('coursesTitle') ?? 'الدورات التعليمية'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.translate('searchCourse') ?? 'ابحث عن دورة...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              coursesProvider.filterCourses(searchQuery: '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    coursesProvider.filterCourses(searchQuery: value);
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip(
                      AppLocalizations.of(context)?.translate('all') ?? 'الكل',
                      coursesProvider.selectedLevel == 'الكل',
                      () => coursesProvider.filterCourses(level: 'الكل'),
                    ),
                    ...AppConstants.courseLevels.map((level) => _buildFilterChip(
                      _getLocalizedLevel(level, context),
                      coursesProvider.selectedLevel == level,
                      () => coursesProvider.filterCourses(level: level),
                    )),
                    const SizedBox(width: 16),
                    const Text('|', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 16),
                    _buildFilterChip(
                      AppLocalizations.of(context)?.translate('all') ?? 'الكل',
                      coursesProvider.selectedCategory == 'الكل',
                      () => coursesProvider.filterCourses(category: 'الكل'),
                    ),
                    _buildFilterChip(
                      AppLocalizations.of(context)?.translate('machineLearning') ?? 'تعلم الآلة',
                      coursesProvider.selectedCategory == 'تعلم الآلة',
                      () => coursesProvider.filterCourses(category: 'تعلم الآلة'),
                    ),
                    _buildFilterChip(
                      AppLocalizations.of(context)?.translate('naturalLanguageProcessing') ?? 'معالجة اللغات الطبيعية',
                      coursesProvider.selectedCategory == 'معالجة اللغات الطبيعية',
                      () => coursesProvider.filterCourses(category: 'معالجة اللغات الطبيعية'),
                    ),
                    _buildFilterChip(
                      AppLocalizations.of(context)?.translate('computerVision') ?? 'رؤية الحاسوب',
                      coursesProvider.selectedCategory == 'رؤية الحاسوب',
                      () => coursesProvider.filterCourses(category: 'رؤية الحاسوب'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: coursesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : coursesProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(coursesProvider.error!),
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
                      crossAxisCount: isWideScreen ? 3 : 1,
                      childAspectRatio: isWideScreen ? 1.1 : 1.3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: coursesProvider.courses.length,
                    itemBuilder: (context, index) {
                      final course = coursesProvider.courses[index];
                      return _buildCourseCard(context, course);
                    },
                  ),
                ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, dynamic course) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Provider.of<CoursesProvider>(context, listen: false).selectCourse(course.id);
          context.go('/course/${course.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: course.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            _getLocalizedCourseTitle(course, context),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _getLocalizedInstructorName(course, context),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                course.rating.toString(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '(${course.totalRatings})',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getLocalizedLevel(course.level, context),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                flex: 1,
                                child: Text(
                                  course.isFree 
                                      ? (AppLocalizations.of(context)?.translate('free') ?? 'مجاني')
                                      : '${course.price.toInt()} ${AppLocalizations.of(context)?.translate('sar') ?? 'ر.س'}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: course.isFree ? Colors.green : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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