import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import 'modern_post_card.dart';

/// A reusable community widget with categories and compact post cards
class CommunityWidget extends StatefulWidget {
  const CommunityWidget({super.key});

  @override
  State<CommunityWidget> createState() => _CommunityWidgetState();
}

class _CommunityWidgetState extends State<CommunityWidget> {
  String _selectedCategory = 'all';

  // Categories list
  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'الكل', 'icon': Icons.apps},
    {'id': 'programming', 'name': 'البرمجة', 'icon': Icons.code},
    {'id': 'ai', 'name': 'الذكاء الاصطناعي', 'icon': Icons.psychology},
    {'id': 'design', 'name': 'التصميم', 'icon': Icons.brush},
    {'id': 'languages', 'name': 'اللغات', 'icon': Icons.language},
    {'id': 'job_offers', 'name': 'إعلانات وظائف', 'icon': Icons.work},
    {'id': 'job_search', 'name': 'البحث عن وظائف', 'icon': Icons.search},
    {'id': 'general', 'name': 'عام', 'icon': Icons.forum},
  ];

  String _getLocalizedPostTitle(dynamic post, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (post.id) {
      case '1':
        return localizations?.translate('discussionTitle1') ?? post.title;
      case '2':
        return localizations?.translate('discussionTitle2') ?? post.title;
      case '3':
        return localizations?.translate('discussionTitle3') ?? post.title;
      case '4':
        return localizations?.translate('discussionTitle4') ?? post.title;
      default:
        return post.title;
    }
  }

  String _getLocalizedPostContent(dynamic post, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (post.id) {
      case '1':
        return localizations?.translate('discussionContent1') ?? post.content;
      case '2':
        return localizations?.translate('discussionContent2') ?? post.content;
      case '3':
        return localizations?.translate('discussionContent3') ?? post.content;
      case '4':
        return localizations?.translate('discussionContent4') ?? post.content;
      default:
        return post.content;
    }
  }

  String _getLocalizedUserName(dynamic post, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (post.userId) {
      case '1':
        return localizations?.translate('userName1') ?? post.userName;
      case '2':
        return localizations?.translate('userName2') ?? post.userName;
      case '3':
        return localizations?.translate('userName3') ?? post.userName;
      case '4':
        return localizations?.translate('userName4') ?? post.userName;
      default:
        return post.userName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 768;

    return Column(
      children: [
        // Header with title and new post button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.translate('communityTitle') ?? 'المجتمع',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Sort dropdown
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort, size: 20),
                    onSelected: (value) => communityProvider.setSortBy(value),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'recent',
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 18),
                            SizedBox(width: 8),
                            Text('الأحدث'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'popular',
                        child: Row(
                          children: [
                            Icon(Icons.trending_up, size: 18),
                            SizedBox(width: 8),
                            Text('الأكثر شعبية'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Add new post button
                  ElevatedButton.icon(
                    onPressed: () => _showCreatePostDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('منشور جديد'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Categories tabs
        Container(
          height: 60,
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['id'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'],
                        size: 16,
                        color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category['name'],
                        style: TextStyle(
                          color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[700],
                          fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category['id'];
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  checkmarkColor: Theme.of(context).primaryColor,
                  side: BorderSide(
                    color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              );
            },
          ),
        ),
        // Main content area with modern cards
        Expanded(
          child: communityProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => communityProvider.loadPosts(),
                  child: _buildPostsList(communityProvider, isWideScreen),
                ),
        ),
      ],
    );
  }

  Widget _buildPostsList(CommunityProvider provider, bool isWideScreen) {
    final filteredPosts = _filterPostsByCategory(provider.posts);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        Widget postCard = ModernPostCard(
          post: post,
          onTap: () {
            // Post details screen removed
          },
          onLike: () {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final userId = authProvider.currentUser?.id ?? 'guest_user';
            provider.votePost(post.id, true, userId);
          },
          onComment: () => _showCommentsDialog(context, post, provider),
          getLocalizedTitle: (post) => _getLocalizedPostTitle(post, context),
          getLocalizedContent: (post) => _getLocalizedPostContent(post, context),
          getLocalizedUserName: (post) => _getLocalizedUserName(post, context),
          formatTime: (time) => _formatTime(time, context),
          categoryName: _getCategoryName(post.category),
        );

        // Center the post card on desktop with max width
        if (isWideScreen) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: postCard,
            ),
          );
        }

        return postCard;
      },
    );
  }

  // Filter posts by selected category
  List<dynamic> _filterPostsByCategory(List<dynamic> posts) {
    if (_selectedCategory == 'all') {
      return posts;
    }

    // Filter posts based on category field first, then tags
    return posts.where((post) {
      // Check category field first
      if (post.category == _selectedCategory) {
        return true;
      }

      // Fallback to tag-based filtering for backward compatibility
      final tags = post.tags as List<String>? ?? [];

      switch (_selectedCategory) {
        case 'programming':
          return tags.any((tag) =>
            tag.contains('برمجة') ||
            tag.contains('Flutter') ||
            tag.contains('React') ||
            tag.contains('OpenAI') ||
            tag.contains('GPT')
          );
        case 'ai':
          return tags.any((tag) =>
            tag.contains('ذكاء') ||
            tag.contains('AI') ||
            tag.contains('GPT') ||
            tag.contains('Claude')
          );
        case 'design':
          return tags.any((tag) =>
            tag.contains('تصميم') ||
            tag.contains('UI') ||
            tag.contains('UX')
          );
        case 'languages':
          return tags.any((tag) =>
            tag.contains('لغة') ||
            tag.contains('عربي') ||
            tag.contains('إنجليزي')
          );
        case 'job_offers':
          return post.title.contains('وظيفة') ||
                 post.title.contains('توظيف') ||
                 tags.any((tag) => tag.contains('وظيفة'));
        case 'job_search':
          return post.title.contains('البحث عن عمل') ||
                 tags.any((tag) => tag.contains('بحث عن عمل'));
        case 'general':
          return tags.any((tag) => tag.contains('عام') || tag.contains('منتديات'));
        default:
          return true;
      }
    }).toList();
  }

  void _showCommentsDialog(BuildContext context, dynamic post, CommunityProvider communityProvider) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Text(
                    'التعليقات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<CommunityProvider>(
                builder: (context, provider, child) {
                  final currentPost = provider.posts.firstWhere((p) => p.id == post.id, orElse: () => post);
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentPost.comments.length,
                    itemBuilder: (context, index) {
                      final comment = currentPost.comments[index];
                      return _CommentItem(
                        comment: comment,
                        formatTime: (time) => _formatTime(time, context),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب تعليقاً...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () async {
                      if (commentController.text.trim().isNotEmpty) {
                        final text = commentController.text.trim();
                        commentController.clear();
                        await communityProvider.addComment(post.id, text, context);
                      }
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

  void _showCreatePostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();
    String selectedCategory = _selectedCategory == 'all' ? 'general' : _selectedCategory;
    List<String> imageUrls = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.post_add, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('إنشاء منشور جديد'),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category selection
                      const Text(
                        'اختر الفئة:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: _categories
                            .where((cat) => cat['id'] != 'all')
                            .map((category) {
                          final isSelected = selectedCategory == category['id'];
                          return ChoiceChip(
                            selected: isSelected,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category['icon'],
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(category['name']),
                              ],
                            ),
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = category['id'];
                              });
                            },
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Title input
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان المنشور',
                          hintText: 'أدخل عنوان المنشور',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Content input
                      TextField(
                        controller: contentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'محتوى المنشور',
                          hintText: 'اكتب محتوى المنشور هنا...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Image URL input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'رابط الصورة (اختياري)',
                                hintText: 'أدخل رابط الصورة',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.image),
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    imageUrls.add(value);
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Simulate image upload
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('رفع صورة'),
                                  content: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'رابط الصورة',
                                      hintText: 'https://example.com/image.jpg',
                                    ),
                                    onSubmitted: (value) {
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          imageUrls.add(value);
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('إلغاء'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.upload, size: 16),
                            label: const Text('رفع'),
                          ),
                        ],
                      ),
                      // Display added images
                      if (imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: imageUrls.map((url) {
                            return Chip(
                              label: Text('صورة ${imageUrls.indexOf(url) + 1}'),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  imageUrls.remove(url);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Tags input
                      TextField(
                        controller: tagsController,
                        decoration: const InputDecoration(
                          labelText: 'الكلمات المفتاحية (اختياري)',
                          hintText: 'مثل: Flutter، AI، تعلم (افصل بفاصلة)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.tag),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('نشر'),
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        contentController.text.isNotEmpty) {
                      final tags = tagsController.text.isNotEmpty
                          ? tagsController.text
                              .split(',')
                              .map((tag) => tag.trim())
                              .where((tag) => tag.isNotEmpty)
                              .toList()
                          : <String>[];

                      Provider.of<CommunityProvider>(context, listen: false)
                          .createPost(
                        titleController.text,
                        contentController.text,
                        selectedCategory,
                        tags,
                        imageUrls,
                        context,
                      );

                      Navigator.of(dialogContext).pop();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم نشر المنشور في قسم ${_categories.firstWhere((cat) => cat['id'] == selectedCategory)['name']}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء ملء جميع الحقول المطلوبة'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String? _getCategoryName(String? categoryId) {
    if (categoryId == null) return null;

    final category = _categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'name': ''},
    );

    return category['name'];
  }

  String _formatTime(DateTime time, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}

// Comment Item Widget
class _CommentItem extends StatelessWidget {
  final dynamic comment;
  final String Function(DateTime) formatTime;

  const _CommentItem({
    required this.comment,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.userPhotoUrl != null
                ? NetworkImage(comment.userPhotoUrl!)
                : null,
            child: comment.userPhotoUrl == null
                ? Text(comment.userName[0], style: const TextStyle(fontSize: 12))
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatTime(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}