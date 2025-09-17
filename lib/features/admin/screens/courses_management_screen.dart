import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';

class CoursesManagementScreen extends StatefulWidget {
  const CoursesManagementScreen({super.key});

  @override
  State<CoursesManagementScreen> createState() => _CoursesManagementScreenState();
}

class _CoursesManagementScreenState extends State<CoursesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          if (isDesktop)
            AdminSidebar(
              selectedIndex: 1,
              onItemSelected: (index) {
                _navigateToSection(index);
              },
            ),

          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (!isDesktop)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      const SizedBox(width: 16),
                      Text(
                        'إدارة الدورات',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showCourseDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة دورة جديدة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search and filters
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'البحث عن دورة...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            context.read<AdminProvider>().searchCourses(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('جميع الدورات')),
                            DropdownMenuItem(value: 'published', child: Text('منشورة')),
                            DropdownMenuItem(value: 'draft', child: Text('مسودة')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Courses table
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
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
                    child: Consumer<AdminProvider>(
                      builder: (context, adminProvider, child) {
                        if (adminProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final courses = adminProvider.courses;

                        if (courses.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد دورات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('الصورة')),
                              DataColumn(label: Text('العنوان')),
                              DataColumn(label: Text('التصنيف')),
                              DataColumn(label: Text('المدرس')),
                              DataColumn(label: Text('السعر')),
                              DataColumn(label: Text('المسجلين')),
                              DataColumn(label: Text('الحالة')),
                              DataColumn(label: Text('الإجراءات')),
                            ],
                            rows: courses.map((course) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[200],
                                      ),
                                      child: course.thumbnailUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                course.thumbnailUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(Icons.image, color: Colors.grey);
                                                },
                                              ),
                                            )
                                          : const Icon(Icons.image, color: Colors.grey),
                                    ),
                                  ),
                                  DataCell(Text(course.title)),
                                  DataCell(Text(course.category)),
                                  DataCell(Text(course.instructorName)),
                                  DataCell(Text('\$${course.price.toStringAsFixed(2)}')),
                                  DataCell(Text(course.enrolledStudents.toString())),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: course.isPublished
                                            ? Colors.green[50]
                                            : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        course.isPublished ? 'منشورة' : 'مسودة',
                                        style: TextStyle(
                                          color: course.isPublished
                                              ? Colors.green
                                              : Colors.orange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () {
                                            _showCourseDialog(course: course);
                                          },
                                          color: Colors.blue,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          onPressed: () {
                                            _showDeleteConfirmation(course);
                                          },
                                          color: Colors.red,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isDesktop
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: 1,
                onItemSelected: (index) {
                  Navigator.pop(context);
                  _navigateToSection(index);
                },
              ),
            )
          : null,
    );
  }

  void _navigateToSection(int index) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        // Already on courses
        break;
      case 2:
        context.go('/admin/users');
        break;
      case 3:
        context.go('/admin/content');
        break;
      case 4:
        context.go('/admin/finance');
        break;
      case 5:
        context.go('/admin/settings');
        break;
    }
  }

  void _showCourseDialog({CourseModel? course}) {
    final isEdit = course != null;
    final titleController = TextEditingController(text: course?.title ?? '');
    final descriptionController = TextEditingController(text: course?.description ?? '');
    final categoryController = TextEditingController(text: course?.category ?? '');
    final priceController = TextEditingController(
      text: course?.price.toString() ?? '',
    );
    final instructorController = TextEditingController(text: course?.instructorName ?? '');
    final durationController = TextEditingController(text: course?.duration.toString() ?? '');
    final levelController = TextEditingController(text: course?.level ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'تعديل الدورة' : 'إضافة دورة جديدة'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الدورة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'التصنيف',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: instructorController,
                    decoration: const InputDecoration(
                      labelText: 'المدرس',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'المدة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: course?.level ?? 'مبتدئ',
                    decoration: const InputDecoration(
                      labelText: 'المستوى',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'مبتدئ', child: Text('مبتدئ')),
                      DropdownMenuItem(value: 'متوسط', child: Text('متوسط')),
                      DropdownMenuItem(value: 'متقدم', child: Text('متقدم')),
                    ],
                    onChanged: (value) {
                      levelController.text = value!;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى إدخال عنوان الدورة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final courseData = {
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'category': categoryController.text.trim(),
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'instructor': instructorController.text.trim(),
                  'instructorName': instructorController.text.trim(),
                  'duration': int.tryParse(durationController.text) ?? 1,
                  'level': levelController.text.trim().isNotEmpty ? levelController.text.trim() : 'مبتدئ',
                  'isPublished': true,
                };

                Navigator.pop(context);

                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري حفظ الدورة...'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 1),
                  ),
                );

                if (isEdit && course != null) {
                  // Update course
                  final success = await context.read<AdminProvider>().updateCourse(course.id, courseData);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث الدورة بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('فشل في تحديث الدورة'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  // Create new course
                  final courseId = await context.read<AdminProvider>().createCourse(courseData);
                  if (courseId != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة الدورة بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('فشل في إضافة الدورة'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'حفظ التغييرات' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف دورة "${course.title}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري حذف الدورة...'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 1),
                  ),
                );

                final success = await context.read<AdminProvider>().deleteCourse(course.id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف الدورة بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('فشل في حذف الدورة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
