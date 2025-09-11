import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

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
      appBar: AppBar(
        title: const Text('جميع الدورات'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
            if (selectedCategory != null &&
                course.category != selectedCategory) {
              return false;
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
                                  label: const Text('البرمجة'),
                                  selected: selectedCategory == 'programming',
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedCategory = selected
                                          ? 'programming'
                                          : null;
                                    });
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                child: ChoiceChip(
                                  label: const Text('الرياضيات'),
                                  selected: selectedCategory == 'mathematics',
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedCategory = selected
                                          ? 'mathematics'
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
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return CourseCard(course: filteredCourses[index]);
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
