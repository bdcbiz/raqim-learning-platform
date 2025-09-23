import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/course_provider.dart';
import '../widgets/common/animated_course_card.dart';
import '../widgets/common/modern_course_card.dart' show ModernCourseCard;
import 'course_detail_screen.dart';
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
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/images/raqimLogo.svg',
            height: 28,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.srcIn,
            ),
          ),
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
      body: Consumer<CourseProvider>(
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
            if (selectedLevel != null && course.level != selectedLevel) {
              return false;
            }
            return true;
          }).toList();

          return RefreshIndicator(
            onRefresh: () => courseProvider.loadCourses(),
            child: CustomScrollView(
              slivers: [
                // Search Bar with Filter
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'ابحث عن الدورات...',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Filter Button
                            Container(
                              decoration: BoxDecoration(
                                color: _showFilters ? AppColors.primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.filter_list,
                                  color: _showFilters ? Colors.white : AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showFilters = !_showFilters;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        // Filters Section (Animated)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: _showFilters ? null : 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _showFilters ? 1 : 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  'الفئات',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      // Category filter
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('جميع الفئات'),
                                          selected: selectedCategory == null,
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('الذكاء الاصطناعي'),
                                          selected: selectedCategory == 'الذكاء الاصطناعي',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'الذكاء الاصطناعي'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('تعلم الآلة'),
                                          selected: selectedCategory == 'تعلم الآلة',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'تعلم الآلة'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('معالجة اللغات'),
                                          selected: selectedCategory == 'معالجة اللغات',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'معالجة اللغات'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('رؤية الحاسوب'),
                                          selected: selectedCategory == 'رؤية الحاسوب',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'رؤية الحاسوب'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('التعلم العميق'),
                                          selected: selectedCategory == 'التعلم العميق',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'التعلم العميق'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('Python'),
                                          selected: selectedCategory == 'Python',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'Python'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('علم البيانات'),
                                          selected: selectedCategory == 'علم البيانات',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'علم البيانات'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('البرمجة'),
                                          selected: selectedCategory == 'البرمجة',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'البرمجة'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('الذكاء التوليدي'),
                                          selected: selectedCategory == 'الذكاء التوليدي',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'الذكاء التوليدي'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('التقنية'),
                                          selected: selectedCategory == 'technology',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedCategory = selected
                                                  ? 'technology'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'المستويات',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      // Level filter
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('جميع المستويات'),
                                          selected: selectedLevel == null,
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedLevel = null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('مبتدئ'),
                                          selected: selectedLevel == 'beginner',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedLevel = selected
                                                  ? 'beginner'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('متوسط'),
                                          selected: selectedLevel == 'intermediate',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedLevel = selected
                                                  ? 'intermediate'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: const Text('متقدم'),
                                          selected: selectedLevel == 'advanced',
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedLevel = selected
                                                  ? 'advanced'
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600
                            ? 3
                            : 2,
                        childAspectRatio: 1.05,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final course = filteredCourses[index];
                        return CoursesScreenCard(
                          course: course,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailScreen(course: course),
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
          );
        },
      ),
    );
  }
}

class CoursesScreenCard extends StatelessWidget {
  final dynamic course;
  final VoidCallback onTap;

  const CoursesScreenCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail with status overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Container(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: course.thumbnail != null
                          ? Image.network(
                              course.thumbnail!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.play_circle_outline,
                                  size: 32,
                                  color: Colors.white70,
                                );
                              },
                            )
                          : const Icon(
                              Icons.play_circle_outline,
                              size: 32,
                              color: Colors.white70,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: course.price == 0 ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.price == 0 ? 'مجاني' : '${course.price} ريال',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Course info - Fixed height container
            Container(
              height: 60,
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title only
                  Text(
                    course.titleAr ?? course.title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Bottom row with stats and button
                  Row(
                    children: [
                      // Small rating
                      Icon(
                        Icons.star,
                        size: 10,
                        color: Colors.amber,
                      ),
                      Text(
                        '${course.rating?.toStringAsFixed(1) ?? '4.5'}',
                        style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Simple price or button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: course.price == 0 ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'تفاصيل',
                          style: TextStyle(
                            fontSize: 7,
                            color: course.price == 0 ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}