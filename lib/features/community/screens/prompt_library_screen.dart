import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/raqim_app_bar.dart';
import '../models/prompt_post.dart';
import '../providers/community_provider.dart';

class PromptLibraryScreen extends StatefulWidget {
  const PromptLibraryScreen({super.key});

  @override
  State<PromptLibraryScreen> createState() => _PromptLibraryScreenState();
}

class _PromptLibraryScreenState extends State<PromptLibraryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'الكل';
  String _selectedDifficulty = 'الكل';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'الكل',
    'إبداعي',
    'برمجة',
    'أعمال',
    'تعليم',
    'تسويق',
    'كتابة',
    'تحليل',
    'أخرى',
  ];

  final List<String> _difficulties = ['الكل', 'مبتدئ', 'متوسط', 'متقدم'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadPrompts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<PromptPost> _getFilteredPrompts(List<PromptPost> prompts) {
    return prompts.where((prompt) {
      final matchesCategory = _selectedCategory == 'الكل' ||
          prompt.categoryDisplayName == _selectedCategory;
      final matchesDifficulty = _selectedDifficulty == 'الكل' ||
          prompt.difficultyDisplayName == _selectedDifficulty;
      final matchesSearch = _searchQuery.isEmpty ||
          prompt.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prompt.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prompt.tags.any((tag) =>
              tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesDifficulty && matchesSearch;
    }).toList();
  }

  List<PromptPost> _getPopularPrompts(List<PromptPost> prompts) {
    final filtered = _getFilteredPrompts(prompts);
    filtered.sort((a, b) => b.likes.compareTo(a.likes));
    return filtered.take(20).toList();
  }

  List<PromptPost> _getRecentPrompts(List<PromptPost> prompts) {
    final filtered = _getFilteredPrompts(prompts);
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.take(20).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const RaqimAppBar(
        title: 'مكتبة البرومبت',
        showLogo: false,
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'ابحث عن البرومبت...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'الفئة',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDifficulty,
                        decoration: InputDecoration(
                          labelText: 'المستوى',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _difficulties.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppColors.primaryColor,
              tabs: const [
                Tab(text: 'الكل'),
                Tab(text: 'الأكثر شعبية'),
                Tab(text: 'الأحدث'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Consumer<CommunityProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // All Prompts
                    _buildPromptsList(_getFilteredPrompts(provider.prompts)),
                    // Popular Prompts
                    _buildPromptsList(_getPopularPrompts(provider.prompts)),
                    // Recent Prompts
                    _buildPromptsList(_getRecentPrompts(provider.prompts)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreatePromptDialog(context);
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'إضافة برومبت',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPromptsList(List<PromptPost> prompts) {
    if (prompts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد برومبت تطابق البحث',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        return _buildPromptCard(prompt);
      },
    );
  }

  Widget _buildPromptCard(PromptPost prompt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: prompt.authorAvatar != null
                      ? NetworkImage(prompt.authorAvatar!)
                      : null,
                  backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                  child: prompt.authorAvatar == null
                      ? Text(
                          prompt.authorName.isNotEmpty
                              ? prompt.authorName[0].toUpperCase()
                              : '؟',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            prompt.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (prompt.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatDate(prompt.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePromptAction(value, prompt),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy),
                          SizedBox(width: 8),
                          Text('نسخ البرومبت'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('مشاركة'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title and Description
            Text(
              prompt.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prompt.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Tags and Category
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(
                  prompt.categoryDisplayName,
                  AppColors.primaryColor,
                ),
                _buildChip(
                  prompt.difficultyDisplayName,
                  _getDifficultyColor(prompt.difficulty),
                ),
                if (prompt.aiTool != null)
                  _buildChip(
                    prompt.aiTool!,
                    Colors.blue,
                  ),
                ...prompt.tags.take(3).map((tag) => _buildChip(
                      tag,
                      Colors.grey,
                    )),
              ],
            ),
            const SizedBox(height: 12),

            // Stats and Actions
            Row(
              children: [
                _buildStatItem(Icons.favorite, prompt.likes.toString()),
                const SizedBox(width: 16),
                _buildStatItem(Icons.copy, prompt.copies.toString()),
                const SizedBox(width: 16),
                _buildStatItem(Icons.visibility, prompt.views.toString()),
                const Spacer(),
                TextButton(
                  onPressed: () => _showPromptDetails(prompt),
                  child: const Text('عرض التفاصيل'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(PromptDifficulty difficulty) {
    switch (difficulty) {
      case PromptDifficulty.beginner:
        return Colors.green;
      case PromptDifficulty.intermediate:
        return Colors.orange;
      case PromptDifficulty.advanced:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  void _handlePromptAction(String action, PromptPost prompt) {
    switch (action) {
      case 'copy':
        Clipboard.setData(ClipboardData(text: prompt.promptText));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نسخ البرومبت'),
            backgroundColor: Colors.green,
          ),
        );
        context.read<CommunityProvider>().copyPrompt(prompt.id);
        break;
      case 'share':
        // Implement sharing functionality
        break;
    }
  }

  void _showPromptDetails(PromptPost prompt) {
    showDialog(
      context: context,
      builder: (context) => PromptDetailsDialog(prompt: prompt),
    );
  }

  void _showCreatePromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreatePromptDialog(),
    );
  }
}

class PromptDetailsDialog extends StatelessWidget {
  final PromptPost prompt;

  const PromptDetailsDialog({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    prompt.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              prompt.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),

            // Prompt Text
            const Text(
              'البرومبت:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                prompt.promptText,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Example Output (if available)
            if (prompt.exampleOutput != null) ...[
              const Text(
                'مثال على النتيجة:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  prompt.exampleOutput!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: prompt.promptText));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ البرومبت'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('نسخ البرومبت'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Like functionality
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: const Text(
                    'أعجبني',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePromptDialog extends StatefulWidget {
  const CreatePromptDialog({super.key});

  @override
  State<CreatePromptDialog> createState() => _CreatePromptDialogState();
}

class _CreatePromptDialogState extends State<CreatePromptDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _promptController = TextEditingController();
  final _tagsController = TextEditingController();
  PromptCategory _selectedCategory = PromptCategory.creative;
  PromptDifficulty _selectedDifficulty = PromptDifficulty.beginner;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _promptController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'إضافة برومبت جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Prompt Text
              TextField(
                controller: _promptController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'نص البرومبت',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Category and Difficulty
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<PromptCategory>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'الفئة',
                        border: OutlineInputBorder(),
                      ),
                      items: PromptCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryDisplayName(category)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<PromptDifficulty>(
                      initialValue: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'المستوى',
                        border: OutlineInputBorder(),
                      ),
                      items: PromptDifficulty.values.map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(_getDifficultyDisplayName(difficulty)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tags
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'الهاشتاج (مفصولة بفواصل)',
                  border: OutlineInputBorder(),
                  helperText: 'مثال: تصميم, إبداع, تسويق',
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitPrompt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text(
                      'نشر',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(PromptCategory category) {
    switch (category) {
      case PromptCategory.creative:
        return 'إبداعي';
      case PromptCategory.coding:
        return 'برمجة';
      case PromptCategory.business:
        return 'أعمال';
      case PromptCategory.education:
        return 'تعليم';
      case PromptCategory.marketing:
        return 'تسويق';
      case PromptCategory.writing:
        return 'كتابة';
      case PromptCategory.analysis:
        return 'تحليل';
      case PromptCategory.other:
        return 'أخرى';
    }
  }

  String _getDifficultyDisplayName(PromptDifficulty difficulty) {
    switch (difficulty) {
      case PromptDifficulty.beginner:
        return 'مبتدئ';
      case PromptDifficulty.intermediate:
        return 'متوسط';
      case PromptDifficulty.advanced:
        return 'متقدم';
    }
  }

  void _submitPrompt() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final prompt = PromptPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      promptText: _promptController.text,
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      authorId: 'current_user_id',
      authorName: 'المستخدم الحالي',
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<CommunityProvider>().addPrompt(prompt);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إضافة البرومبت بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }
}