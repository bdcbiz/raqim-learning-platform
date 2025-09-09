import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _isUploading = true;
        });

        // في تطبيق حقيقي، سترفع الصورة إلى السيرفر هنا
        // وتحصل على URL للصورة المرفوعة
        // لكن في هذا المثال، سنستخدم المسار المحلي فقط

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // للويب، نستخدم المسار مباشرة
        // للموبايل، نستخدم File path
        String imagePath = image.path;
        
        await authProvider.updateProfileImage(imagePath);

        setState(() {
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.translate('profileImageUpdated') ?? 'تم تحديث صورة الملف الشخصي بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)?.translate('errorOccurred') ?? 'حدث خطأ'}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)?.translate('chooseImageSource') ?? 'اختر مصدر الصورة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(AppLocalizations.of(context)?.translate('gallery') ?? 'المعرض'),
                  subtitle: Text(AppLocalizations.of(context)?.translate('chooseFromGallery') ?? 'اختر صورة من معرض الصور'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context);
                  },
                ),
                if (!kIsWeb) ...[
                  const SizedBox(height: 10),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(AppLocalizations.of(context)?.translate('camera') ?? 'الكاميرا'),
                    subtitle: Text(AppLocalizations.of(context)?.translate('takeNewPhoto') ?? 'التقط صورة جديدة'),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 512,
                          maxHeight: 512,
                          imageQuality: 75,
                        );

                        if (image != null) {
                          setState(() {
                            _isUploading = true;
                          });

                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.updateProfileImage(image.path);

                          setState(() {
                            _isUploading = false;
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تحديث صورة الملف الشخصي بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        setState(() {
                          _isUploading = false;
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${AppLocalizations.of(context)?.translate('errorOccurred') ?? 'حدث خطأ'}: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(dynamic user) {
    if (user?.photoUrl != null) {
      // Check if it's a local file path or network URL
      if (user.photoUrl.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            user.photoUrl,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(user);
            },
          ),
        );
      } else if (!kIsWeb) {
        // For mobile, display local file
        return ClipOval(
          child: Image.file(
            File(user.photoUrl),
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(user);
            },
          ),
        );
      } else {
        // For web, we can't display local file directly
        // In production, you'd upload to server and get URL
        return _buildDefaultAvatar(user);
      }
    }
    return _buildDefaultAvatar(user);
  }

  Widget _buildDefaultAvatar(dynamic user) {
    return Text(
      user?.name.substring(0, 1).toUpperCase() ?? 'U',
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('profile') ?? 'الملف الشخصي'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : _buildProfileImage(user),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _isUploading
                                ? null
                                : () => _showImageSourceDialog(context),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'المستخدم',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.school),
                          title: Text(AppLocalizations.of(context)?.translate('enrolledCourses') ?? 'الدورات المسجلة'),
                          trailing: Text(
                            '${user?.enrolledCourses.length ?? 0}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.check_circle),
                          title: Text(AppLocalizations.of(context)?.translate('completedCourses') ?? 'الدورات المكتملة'),
                          trailing: Text(
                            '${user?.completedCourses.length ?? 0}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.workspace_premium),
                          title: Text(AppLocalizations.of(context)?.translate('certificates') ?? 'الشهادات'),
                          trailing: Text(
                            '${user?.certificates.length ?? 0}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.star),
                          title: Text(AppLocalizations.of(context)?.translate('points') ?? 'النقاط'),
                          trailing: Text(
                            '${user?.points ?? 0}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.emoji_events),
                          title: Text(AppLocalizations.of(context)?.translate('badges') ?? 'الشارات'),
                          trailing: Text(
                            '${user?.badges.length ?? 0}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(AppLocalizations.of(context)?.translate('logout') ?? 'تسجيل الخروج'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.red,
                      ),
                    ),
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