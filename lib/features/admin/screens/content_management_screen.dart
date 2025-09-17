import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar.dart';
import '../../../core/theme/app_theme.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.loadNews();
      provider.loadCategories();
      provider.loadAdvertisements();
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
              selectedIndex: 3,
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
                        'إدارة المحتوى',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: AppColors.primaryColor,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.newspaper),
                        text: 'الأخبار',
                      ),
                      Tab(
                        icon: Icon(Icons.category),
                        text: 'التصنيفات',
                      ),
                      Tab(
                        icon: Icon(Icons.ads_click),
                        text: 'الإعلانات',
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNewsTab(),
                      _buildCategoriesTab(),
                      _buildAdvertisementsTab(),
                    ],
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
                selectedIndex: 3,
                onItemSelected: (index) {
                  Navigator.pop(context);
                  _navigateToSection(index);
                },
              ),
            )
          : null,
    );
  }

  // News Tab
  Widget _buildNewsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Add news button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showNewsDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة خبر جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // News list
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final news = adminProvider.newsArticles;

                if (news.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.newspaper, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد أخبار',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    final article = news[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: article['imageUrl'] != null && article['imageUrl'].isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    article['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image, color: Colors.grey);
                                    },
                                  ),
                                )
                              : const Icon(Icons.image, color: Colors.grey),
                        ),
                        title: Text(
                          article['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['content'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(article['createdAt']),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showNewsDialog(article: article);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(
                                  'خبر',
                                  article['title'],
                                  () {
                                    adminProvider.deleteNewsArticle(article['id']);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Categories Tab
  Widget _buildCategoriesTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Add category button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showCategoryDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة تصنيف جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Categories grid
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = adminProvider.categories;

                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد تصنيفات',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          _showCategoryDialog(category: category);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category['name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${category['coursesCount'] ?? 0} دورة',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('تعديل'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('حذف', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showCategoryDialog(category: category);
                                      } else if (value == 'delete') {
                                        _showDeleteConfirmation(
                                          'تصنيف',
                                          category['name'],
                                          () {
                                            adminProvider.deleteCategory(category['id']);
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Advertisements Tab
  Widget _buildAdvertisementsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Add ad button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showAdvertisementDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة إعلان جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ads list
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ads = adminProvider.advertisements;

                if (ads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.ads_click, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد إعلانات',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          // Ad image preview
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            child: ad['imageUrl'] != null && ad['imageUrl'].isNotEmpty
                                ? Image.network(
                                    ad['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image, size: 64, color: Colors.grey);
                                    },
                                  )
                                : const Icon(Icons.image, size: 64, color: Colors.grey),
                          ),
                          ListTile(
                            title: Text(
                              'موضع: ${ad['position'] ?? 'غير محدد'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الرابط: ${ad['targetUrl'] ?? 'لا يوجد'}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      ad['isActive'] == true
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: ad['isActive'] == true
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ad['isActive'] == true ? 'نشط' : 'غير نشط',
                                      style: TextStyle(
                                        color: ad['isActive'] == true
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: ad['isActive'] ?? false,
                                  onChanged: (value) {
                                    adminProvider.toggleAdvertisement(ad['id'], value);
                                  },
                                  activeThumbColor: Colors.green,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmation(
                                      'إعلان',
                                      'هذا الإعلان',
                                      () {
                                        adminProvider.deleteAdvertisement(ad['id']);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Dialogs
  void _showNewsDialog({Map<String, dynamic>? article}) {
    final isEdit = article != null;
    final titleController = TextEditingController(text: article?['title'] ?? '');
    final contentController = TextEditingController(text: article?['content'] ?? '');
    final imageUrlController = TextEditingController(text: article?['imageUrl'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'تعديل الخبر' : 'إضافة خبر جديد'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الخبر',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'محتوى الخبر',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الصورة',
                      border: OutlineInputBorder(),
                    ),
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
              onPressed: () {
                final newsData = {
                  'title': titleController.text,
                  'content': contentController.text,
                  'imageUrl': imageUrlController.text,
                };

                if (isEdit) {
                  context.read<AdminProvider>().updateNewsArticle(article['id'], newsData);
                } else {
                  context.read<AdminProvider>().createNewsArticle(newsData);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'تم تحديث الخبر بنجاح' : 'تم إضافة الخبر بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(isEdit ? 'حفظ التغييرات' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showCategoryDialog({Map<String, dynamic>? category}) {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?['name'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'تعديل التصنيف' : 'إضافة تصنيف جديد'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'اسم التصنيف',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (isEdit) {
                  context.read<AdminProvider>().updateCategory(
                    category['id'],
                    nameController.text,
                  );
                } else {
                  context.read<AdminProvider>().addCategory(nameController.text);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'تم تحديث التصنيف بنجاح' : 'تم إضافة التصنيف بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(isEdit ? 'حفظ التغييرات' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showAdvertisementDialog({Map<String, dynamic>? ad}) {
    final isEdit = ad != null;
    final imageUrlController = TextEditingController(text: ad?['imageUrl'] ?? '');
    final targetUrlController = TextEditingController(text: ad?['targetUrl'] ?? '');
    final positionController = TextEditingController(text: ad?['position'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'تعديل الإعلان' : 'إضافة إعلان جديد'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الصورة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الهدف',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: ad?['position'] ?? 'home_banner',
                    decoration: const InputDecoration(
                      labelText: 'موضع الإعلان',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'home_banner', child: Text('الصفحة الرئيسية')),
                      DropdownMenuItem(value: 'course_list', child: Text('قائمة الدورات')),
                      DropdownMenuItem(value: 'sidebar', child: Text('الشريط الجانبي')),
                    ],
                    onChanged: (value) {
                      positionController.text = value!;
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
              onPressed: () {
                final adData = {
                  'imageUrl': imageUrlController.text,
                  'targetUrl': targetUrlController.text,
                  'position': positionController.text.isEmpty
                      ? 'home_banner'
                      : positionController.text,
                  'isActive': true,
                };

                context.read<AdminProvider>().createAdvertisement(adData);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إضافة الإعلان بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(String type, String name, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف $type "$name"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف $type بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSection(int index) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/courses');
        break;
      case 2:
        context.go('/admin/users');
        break;
      case 3:
        // Already on content
        break;
      case 4:
        context.go('/admin/finance');
        break;
      case 5:
        context.go('/admin/settings');
        break;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'غير محدد';
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      dateTime = DateTime.parse(date);
    } else {
      return 'غير محدد';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}