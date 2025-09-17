import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../data/models/course_model.dart';

class ManageCourseContentDialog extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const ManageCourseContentDialog({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<ManageCourseContentDialog> createState() => _ManageCourseContentDialogState();
}

class _ManageCourseContentDialogState extends State<ManageCourseContentDialog> {
  final _moduleTitleController = TextEditingController();
  final _lessonTitleController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _contentController = TextEditingController();
  final _durationController = TextEditingController();

  List<CourseModule> _modules = [];
  int? _selectedModuleIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingContent();
  }

  @override
  void dispose() {
    _moduleTitleController.dispose();
    _lessonTitleController.dispose();
    _videoUrlController.dispose();
    _contentController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _loadExistingContent() {
    // TODO: Load existing course content from database
    // For now, create sample data
    setState(() {
      _modules = [
        CourseModule(
          id: 'module1',
          title: 'المقدمة',
          duration: const Duration(hours: 2),
          lessons: [
            Lesson(
              id: 'lesson1',
              title: 'ما هي البرمجة؟',
              duration: const Duration(minutes: 30),
              videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              content: 'في هذا الدرس سنتعرف على مفهوم البرمجة وأساسياتها',
            ),
          ],
        ),
      ];
    });
  }

  void _addModule() {
    if (_moduleTitleController.text.trim().isEmpty) return;

    final newModule = CourseModule(
      id: 'module_${DateTime.now().millisecondsSinceEpoch}',
      title: _moduleTitleController.text.trim(),
      duration: const Duration(hours: 1),
      lessons: [],
    );

    setState(() {
      _modules.add(newModule);
      _moduleTitleController.clear();
    });
  }

  void _addLesson() {
    if (_selectedModuleIndex == null ||
        _lessonTitleController.text.trim().isEmpty) return;

    final newLesson = Lesson(
      id: 'lesson_${DateTime.now().millisecondsSinceEpoch}',
      title: _lessonTitleController.text.trim(),
      duration: Duration(minutes: int.tryParse(_durationController.text) ?? 30),
      videoUrl: _videoUrlController.text.trim().isNotEmpty
          ? _videoUrlController.text.trim()
          : null,
      content: _contentController.text.trim().isNotEmpty
          ? _contentController.text.trim()
          : null,
    );

    setState(() {
      _modules[_selectedModuleIndex!].lessons.add(newLesson);
      _lessonTitleController.clear();
      _videoUrlController.clear();
      _contentController.clear();
      _durationController.clear();
    });
  }

  Future<void> _saveContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save content to database via AdminProvider
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حفظ محتوى الدورة بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ المحتوى: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Module Management Section
                    _buildModuleSection(),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Lesson Management Section
                    _buildLessonSection(),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Current Content Preview
                    _buildContentPreview(),
                  ],
                ),
              ),
            ),

            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            Icons.video_library,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إدارة محتوى الدورة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.courseTitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
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
    );
  }

  Widget _buildModuleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder, color: Color(0xFF667eea)),
                const SizedBox(width: 8),
                const Text(
                  'إضافة وحدة جديدة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _moduleTitleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الوحدة',
                      border: OutlineInputBorder(),
                      hintText: 'مثال: المقدمة، الأساسيات، التطبيق العملي',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addModule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة وحدة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.play_lesson, color: Color(0xFF667eea)),
                const SizedBox(width: 8),
                const Text(
                  'إضافة درس جديد',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Module Selection
            DropdownButtonFormField<int>(
              initialValue: _selectedModuleIndex,
              decoration: const InputDecoration(
                labelText: 'اختر الوحدة',
                border: OutlineInputBorder(),
              ),
              items: _modules.asMap().entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedModuleIndex = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Lesson Details
            TextField(
              controller: _lessonTitleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الدرس',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _videoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الفيديو (اختياري)',
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com/video.mp4',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'المدة (دقائق)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'محتوى الدرس (اختياري)',
                border: OutlineInputBorder(),
                hintText: 'وصف أو ملاحظات حول محتوى الدرس',
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _selectedModuleIndex != null ? _addLesson : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: const Text('إضافة درس'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.preview, color: Color(0xFF667eea)),
                const SizedBox(width: 8),
                const Text(
                  'معاينة المحتوى',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_modules.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'لم يتم إضافة أي محتوى بعد',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _modules.length,
                itemBuilder: (context, moduleIndex) {
                  final module = _modules[moduleIndex];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF667eea),
                        child: Text(
                          '${moduleIndex + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        module.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${module.lessons.length} دروس'),
                      children: module.lessons.map((lesson) {
                        return ListTile(
                          leading: Icon(
                            lesson.videoUrl != null
                                ? Icons.play_circle
                                : Icons.article,
                            color: const Color(0xFF667eea),
                          ),
                          title: Text(lesson.title),
                          subtitle: Text('${lesson.duration.inMinutes} دقيقة'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                module.lessons.remove(lesson);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
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
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveContent,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isLoading ? 'جاري الحفظ...' : 'حفظ المحتوى'),
          ),
        ],
      ),
    );
  }
}