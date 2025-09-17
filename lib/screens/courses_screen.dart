import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../widgets/common/animated_course_card.dart';
import '../widgets/common/modern_course_card.dart' show ModernCourseCard;
import 'course_detail_screen.dart';
import '../core/widgets/raqim_app_bar.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String? selectedCategory;
  String? selectedLevel;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const RaqimAppBar(
        title: 'جميع الدورات',
      ),
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

          // Filter courses based on selected filters
          final filteredCourses = courses.where((course) {
            // Check if course has categories field (for courses with multiple categories)
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
                // Filters
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الفلاتر',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
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
                        childAspectRatio: MediaQuery.of(context).size.width > 600
                            ? 1.05
                            : 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final course = filteredCourses[index];
                        return AnimatedCourseCard(
                          title: course.title,
                          instructor: course.instructorName,
                          imageUrl: course.thumbnail ?? 'https://picsum.photos/400/300?random=${course.id}',
                          category: course.category ?? 'تعلم الآلة',
                          studentsCount: 500,
                          price: course.price == 0 ? 'مجاني' : '${course.price} ريال',
                          rating: course.rating,
                          categoryColor: ModernCourseCard.getCategoryColor(course.category ?? 'تعلم الآلة'),
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
