import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_model.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  UserModel? _selectedUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          if (isDesktop)
            AdminSidebar(
              selectedIndex: 2,
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
                        'إدارة المستخدمين',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Container(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'البحث بالاسم أو البريد الإلكتروني...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      context.read<AdminProvider>().searchUsers(value);
                    },
                  ),
                ),

                // Content area
                Expanded(
                  child: Row(
                    children: [
                      // Users list
                      Expanded(
                        flex: isDesktop ? 2 : 1,
                        child: Container(
                          margin: const EdgeInsets.only(left: 24, bottom: 24),
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

                              final users = adminProvider.users;

                              if (users.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'لا يوجد مستخدمون',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'إجمالي المستخدمين: ${users.length}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: users.length,
                                      itemBuilder: (context, index) {
                                        final user = users[index];
                                        final isSelected = _selectedUser?.id == user.id;

                                        return Card(
                                          color: isSelected
                                              ? AppColors.primaryColor.withValues(alpha: 0.1)
                                              : null,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: AppColors.primaryColor,
                                              child: user.photoUrl != null &&
                                                      user.photoUrl!.isNotEmpty
                                                  ? ClipOval(
                                                      child: Image.network(
                                                        user.photoUrl!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Text(
                                                            user.name[0].toUpperCase(),
                                                            style: const TextStyle(color: Colors.white),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : Text(
                                                      user.name[0].toUpperCase(),
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                            ),
                                            title: Text(
                                              user.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(user.email),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      user.emailVerified
                                                          ? Icons.verified
                                                          : Icons.warning,
                                                      size: 14,
                                                      color: user.emailVerified
                                                          ? Colors.green
                                                          : Colors.orange,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      user.emailVerified
                                                          ? 'تم التحقق'
                                                          : 'لم يتم التحقق',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: user.emailVerified
                                                            ? Colors.green
                                                            : Colors.orange,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _formatDate(user.createdAt),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[50],
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${user.enrolledCourses.length} دورة',
                                                    style: TextStyle(
                                                      color: Colors.blue[700],
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: const Icon(Icons.more_vert),
                                                  onPressed: () {
                                                    _showUserActions(user);
                                                  },
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _selectedUser = user;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // User details panel (Desktop only)
                      if (isDesktop && _selectedUser != null)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 24, bottom: 24),
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
                            child: _buildUserDetails(_selectedUser!),
                          ),
                        ),
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
                selectedIndex: 2,
                onItemSelected: (index) {
                  Navigator.pop(context);
                  _navigateToSection(index);
                },
              ),
            )
          : null,
    );
  }

  Widget _buildUserDetails(UserModel user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryColor,
                child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
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
                    _showEditUserDialog(user);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(user);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // User information
          _buildInfoSection('معلومات الحساب', [
            _buildInfoRow('معرف المستخدم', user.id),
            _buildInfoRow('تاريخ التسجيل', _formatDate(user.createdAt)),
            _buildInfoRow(
              'حالة البريد الإلكتروني',
              user.emailVerified ? 'تم التحقق' : 'لم يتم التحقق',
              color: user.emailVerified ? Colors.green : Colors.orange,
            ),
            _buildInfoRow('النقاط', user.points.toString()),
          ]),

          const SizedBox(height: 24),

          // Enrolled courses
          _buildInfoSection('الدورات المسجلة (${user.enrolledCourses.length})', [
            if (user.enrolledCourses.isEmpty)
              const Text('لا توجد دورات مسجلة')
            else
              ...user.enrolledCourses.map((courseId) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school, color: Colors.grey),
                  ),
                  title: Text('دورة #$courseId'),
                  subtitle: const Text('تقدم: 45%'),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('عرض التفاصيل'),
                  ),
                );
              }).toList(),
          ]),

          const SizedBox(height: 24),

          // Payment history
          _buildInfoSection('سجل المدفوعات', [
            const Text('لا توجد مدفوعات'),
          ]),

          const SizedBox(height: 24),

          // Certificates
          _buildInfoSection('الشهادات (${user.certificates.length})', [
            if (user.certificates.isEmpty)
              const Text('لا توجد شهادات')
            else
              ...user.certificates.map((certId) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                  title: Text('شهادة #$certId'),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('تحميل'),
                  ),
                );
              }).toList(),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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
        // Already on users
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

  void _showUserActions(UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('عرض التفاصيل'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedUser = user;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('تعديل'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditUserDialog(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('إرسال بريد إلكتروني'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('إرسال بريد إلى ${user.email}'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(user);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditUserDialog(UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل المستخدم'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث المستخدم بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف المستخدم "${user.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف المستخدم بنجاح'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}