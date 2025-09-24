import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/course_provider.dart';
import '../widgets/common/elegant_course_card.dart';
import '../widgets/common/modern_search_field.dart';
import '../widgets/common/unified_filter_section.dart';
import 'unified_course_detail_screen.dart';
import '../core/theme/app_theme.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String? selectedCategory;
  String? selectedLevel;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CourseProvider>().loadCourses();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'تعلم الآلة':
      case 'Machine Learning':
        return const Color(0xFF3B82F6);
      case 'معالجة اللغات':
      case 'NLP':
        return const Color(0xFFEF4444);
      case 'رؤية الحاسوب':
      case 'Computer Vision':
        return const Color(0xFF10B981);
      case 'التعلم العميق':
      case 'Deep Learning':
        return const Color(0xFF8B5CF6);
      case 'علم البيانات':
      case 'Data Science':
        return const Color(0xFFF59E0B);
      case 'البرمجة':
      case 'programming':
        return const Color(0xFF06B6D4);
      case 'الذكاء التوليدي':
        return const Color(0xFFDC2626);
      case 'الأعمال':
      case 'business':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'الدورات',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: GestureDetector(
        onTap: () {
          if (_showFilters) {
            setState(() {
              _showFilters = false;
            });
          }
        },
        child: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (courseProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'خطأ في تحميل الدورات',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    courseProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      courseProvider.loadCourses();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final courses = courseProvider.allCourses;

          // Filter courses based on selected filters and search query
          final filteredCourses = courses.where((course) {
            // Search filter
            if (_searchQuery.isNotEmpty) {
              final searchLower = _searchQuery.toLowerCase();
              final titleMatch = course.title.toLowerCase().contains(searchLower) ||
                  course.titleAr.toLowerCase().contains(searchLower);
              final instructorMatch = course.instructorName.toLowerCase().contains(searchLower);
              final categoryMatch = course.category?.toLowerCase().contains(searchLower) ?? false;

              if (!titleMatch && !instructorMatch && !categoryMatch) {
                return false;
              }
            }

            // Category filter
            if (selectedCategory != null) {
              // Try to check in categories array first
              if (course.categories != null && course.categories!.isNotEmpty) {
                if (!course.categories!.contains(selectedCategory)) {
                  return false;
                }
              } else if (course.category != selectedCategory) {
                // Fallback to single category field for backward compatibility
                return false;
              }
            }
            if (selectedLevel != null) {
              // Map Arabic level names to English values for comparison
              String? levelToCheck;
              switch (selectedLevel) {
                case 'مبتدئ':
                  levelToCheck = 'beginner';
                  break;
                case 'متوسط':
                  levelToCheck = 'intermediate';
                  break;
                case 'متقدم':
                  levelToCheck = 'advanced';
                  break;
                default:
                  levelToCheck = selectedLevel;
              }
              if (course.level != levelToCheck) {
                return false;
              }
            }
            return true;
          }).toList();

          return Stack(
            children: [
              // Main content
              RefreshIndicator(
                onRefresh: () => courseProvider.loadCourses(),
                child: CustomScrollView(
                  slivers: [
                    // Search Bar only
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: ModernSearchField(
                          controller: _searchController,
                          hintText: 'ابحث عن دورة...',
                          onChanged: (value) {
                            setState(() {
                              // Search logic will be handled by parent
                            });
                          },
                          suffixIcon: Icons.filter_list,
                          onSuffixIconTap: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                        ),
                      ),
                    ),
                    // Results count
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'النتائج',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${filteredCourses.length} دورة',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    // Courses grid
                    if (filteredCourses.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد دورات متطابقة',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'جرب تغيير الفلاتر',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final course = filteredCourses[index];
                            return ElegantCourseCard(
                              course: course,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UnifiedCourseDetailScreen(course: course),
                                  ),
                                );
                              },
                            );
                          }, childCount: filteredCourses.length),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),

              // Filter overlay
              if (_showFilters)
                Positioned(
                  top: 90, // Position below search bar
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
                          FilterChipData(label: 'الذكاء الاصطناعي', value: 'الذكاء الاصطناعي', type: FilterType.category),
                          FilterChipData(label: 'تعلم الآلة', value: 'تعلم الآلة', type: FilterType.category),
                          FilterChipData(label: 'معالجة اللغات', value: 'معالجة اللغات', type: FilterType.category),
                          FilterChipData(label: 'رؤية الحاسوب', value: 'رؤية الحاسوب', type: FilterType.category),
                          FilterChipData(label: 'التعلم العميق', value: 'التعلم العميق', type: FilterType.category),
                          FilterChipData(label: 'Python', value: 'Python', type: FilterType.category),
                          FilterChipData(label: 'علم البيانات', value: 'علم البيانات', type: FilterType.category),
                          FilterChipData(label: 'البرمجة', value: 'البرمجة', type: FilterType.category),
                          FilterChipData(label: 'الذكاء التوليدي', value: 'الذكاء التوليدي', type: FilterType.category),
                          FilterChipData(label: 'التقنية', value: 'technology', type: FilterType.category),

                          // Levels
                          FilterChipData(label: 'جميع المستويات', value: '', type: FilterType.level),
                          FilterChipData(label: 'مبتدئ', value: 'beginner', type: FilterType.level),
                          FilterChipData(label: 'متوسط', value: 'intermediate', type: FilterType.level),
                          FilterChipData(label: 'متقدم', value: 'advanced', type: FilterType.level),
                        ],
                        selectedCategory: selectedCategory,
                        selectedLevel: selectedLevel ?? '',
                        onCategoryChanged: (value) {
                          setState(() {
                            selectedCategory = value == '' ? null : value;
                          });
                        },
                        onLevelChanged: (value) {
                          setState(() {
                            selectedLevel = value == '' ? null : value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        ),
      ),
    );
  }
}

