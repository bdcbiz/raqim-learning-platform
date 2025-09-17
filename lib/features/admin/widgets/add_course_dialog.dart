import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _thumbnailController = TextEditingController();

  String _selectedCategory = 'البرمجة';
  String _selectedLevel = 'مبتدئ';
  bool _isPublished = true;

  final List<String> _categories = [
    'البرمجة',
    'تعلم الآلة',
    'معالجة اللغات',
    'رؤية الحاسوب',
    'التعلم العميق',
    'علم البيانات',
    'الذكاء التوليدي',
    'الأعمال',
    'التصميم',
    'التسويق',
  ];

  final List<String> _levels = [
    'مبتدئ',
    'متوسط',
    'متقدم',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final courseData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'level': _selectedLevel,
      'instructor': _instructorController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'duration': int.tryParse(_durationController.text) ?? 1,
      'thumbnailUrl': _thumbnailController.text.trim(),
      'isPublished': _isPublished,
    };

    try {
      final adminProvider = context.read<AdminProvider>();
      final courseId = await adminProvider.createCourse(courseData);

      if (courseId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ تم إنشاء الدورة بنجاح وتم مزامنتها مع الموقع والتطبيق!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'إغلاق',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.error ?? 'فشل في إنشاء الدورة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_box,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'إضافة دورة جديدة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sync Notice
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.sync, color: Colors.blue.shade600, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'الدورة ستظهر فوراً في الموقع والتطبيق بعد الإضافة ✨',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Course Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان الدورة *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال عنوان الدورة';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Course Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'وصف الدورة *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال وصف الدورة';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Instructor
                      TextFormField(
                        controller: _instructorController,
                        decoration: const InputDecoration(
                          labelText: 'اسم المدرب *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم المدرب';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Category and Level
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'التصنيف',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedLevel,
                              decoration: const InputDecoration(
                                labelText: 'المستوى',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.trending_up),
                              ),
                              items: _levels.map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(level),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLevel = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Price and Duration
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'السعر (ريال)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                                hintText: '0 = مجاني',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'المدة (ساعات)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.schedule),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'مطلوب';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Thumbnail URL
                      TextFormField(
                        controller: _thumbnailController,
                        decoration: const InputDecoration(
                          labelText: 'رابط الصورة (اختياري)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image),
                          hintText: 'https://example.com/image.jpg',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Published Switch
                      SwitchListTile(
                        title: const Text('نشر الدورة فوراً'),
                        subtitle: const Text('ستظهر للمستخدمين فور الحفظ'),
                        value: _isPublished,
                        onChanged: (value) {
                          setState(() {
                            _isPublished = value;
                          });
                        },
                        secondary: const Icon(Icons.publish),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  Consumer<AdminProvider>(
                    builder: (context, adminProvider, child) {
                      return ElevatedButton(
                        onPressed: adminProvider.isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                        ),
                        child: adminProvider.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('إضافة الدورة'),
                      );
                    },
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