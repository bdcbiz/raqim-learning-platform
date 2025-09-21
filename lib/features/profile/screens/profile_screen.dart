import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import '../../auth/providers/auth_provider.dart';
import '../../../services/auth/auth_interface.dart';
import '../../../services/auth/web_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../widgets/common/raqim_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(BuildContext parentContext) async {
    // Capture scaffold messenger early
    final scaffoldMessenger = ScaffoldMessenger.of(parentContext);
    final authProvider = Provider.of<AuthProvider>(parentContext, listen: false);
    final authService = Provider.of<AuthServiceInterface>(parentContext, listen: false);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null && mounted) {
        setState(() {
          _isUploading = true;
        });

        // Upload image to server and get URL
        try {
          // For web, read bytes and convert to base64
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            // Convert to base64 data URL
            final base64String = base64Encode(bytes);
            final base64Image = 'data:image/png;base64,$base64String';

            // Update both auth services
            await authProvider.updateProfileImage(base64Image);

            // If WebAuthService is available, update it too
            if (authService is WebAuthService) {
              final webAuth = authService as dynamic;
              await webAuth.updateProfilePhoto(base64Image);

              // Force reload user from WebAuthService
              await authService.reloadUser();
            }
          } else {
            // For mobile, upload file to server
            // TODO: Implement actual API upload
            // final response = await ApiService.uploadAvatar(image.path);
            // await authProvider.updateProfileImage(response['url']);

            // For now, use local path
            await authProvider.updateProfileImage(image.path);
          }

          // Force refresh the UI
          if (mounted) {
            setState(() {
              _isUploading = false;
            });

            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('تم تحديث صورة الملف الشخصي بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (uploadError) {
          // If upload fails, still update locally for preview
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            final base64String = base64Encode(bytes);
            final base64Image = 'data:image/png;base64,$base64String';
            await authProvider.updateProfileImage(base64Image);

            // Update WebAuthService too
            if (authService is WebAuthService) {
              final webAuth = authService as dynamic;
              await webAuth.updateProfilePhoto(base64Image);

              // Force reload user from WebAuthService
              await authService.reloadUser();
            }
          } else {
            await authProvider.updateProfileImage(image.path);
          }

          if (mounted) {
            setState(() {
              _isUploading = false;
            });

            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الصورة محلياً'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
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
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: AppColors.primaryColor,
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
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.primaryColor,
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

                          // Upload image to server
                          try {
                            // TODO: Implement actual API upload
                            // final response = await ApiService.uploadAvatar(image.path);
                            // await authProvider.updateProfileImage(response['url']);

                            // For now, use local path
                            await authProvider.updateProfileImage(image.path);
                          } catch (uploadError) {
                            // If upload fails, still update locally
                            await authProvider.updateProfileImage(image.path);
                          }

                          if (mounted) {
                            setState(() {
                              _isUploading = false;
                            });
                          }

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
    print('DEBUG: _buildProfileImage called');
    final photoUrl = user?.photoUrl ?? '';
    print('DEBUG: user photoUrl: ${photoUrl.length > 100 ? photoUrl.substring(0, 100) + '...' : photoUrl}');

    if (user?.photoUrl != null && user.photoUrl.isNotEmpty) {
      // Check if it's a data URL (for web)
      if (user.photoUrl.startsWith('data:')) {
        try {
          print('DEBUG: Processing base64 image');
          // Extract the base64 part from the data URL
          final parts = user.photoUrl.split(',');
          if (parts.length < 2) {
            print('DEBUG: Invalid data URL format');
            return _buildDefaultAvatar(user);
          }
          final base64String = parts[1];
          final imageBytes = base64Decode(base64String);
          print('DEBUG: Decoded ${imageBytes.length} bytes');

          return ClipOval(
            child: Image.memory(
              imageBytes,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('DEBUG: Error loading image: $error');
                return _buildDefaultAvatar(user);
              },
            ),
          );
        } catch (e) {
          print('DEBUG: Exception processing image: $e');
          return _buildDefaultAvatar(user);
        }
      }
      // Check if it's a network URL
      else if (user.photoUrl.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            user.photoUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(user);
            },
          ),
        );
      } else if (!kIsWeb && File(user.photoUrl).existsSync()) {
        // For mobile, display local file
        return ClipOval(
          child: Image.file(
            File(user.photoUrl),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(user);
            },
          ),
        );
      }
    }
    return _buildDefaultAvatar(user);
  }

  Widget _buildDefaultAvatar(dynamic user) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user?.name.substring(0, 1).toUpperCase() ?? 'U',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ?? Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, dynamic user) {
    final nameController = TextEditingController(text: user?.name ?? '');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'تعديل الملف الشخصي',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: user?.email ?? ''),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('الرجاء إدخال اسم صحيح'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );

                      try {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final authService = Provider.of<AuthServiceInterface>(context, listen: false);

                        // Update name in AuthProvider
                        await authProvider.updateUserName(nameController.text.trim());

                        // Update in WebAuthService if available
                        if (authService is WebAuthService) {
                          final webAuth = authService as dynamic;
                          await webAuth.updateUserName(nameController.text.trim());
                          await authService.reloadUser();
                        }

                        // Close loading dialog
                        Navigator.pop(context);

                        // Close edit dialog
                        Navigator.pop(dialogContext);

                        // Force rebuild of the parent widget
                        if (context.mounted) {
                          setState(() {});
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تحديث الملف الشخصي بنجاح'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        // Close loading dialog
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('حدث خطأ: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'حفظ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.all(16),
        );
      },
    ).then((_) {
      // Force rebuild after dialog closes to ensure UI updates
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Try to get user from WebAuthService first (for web)
    final authService = Provider.of<AuthServiceInterface>(context);
    final webUser = authService.currentUser;

    // Fallback to AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = webUser ?? authProvider.currentUser;

    print('DEBUG: Profile build - webUser: ${webUser?.email}, authProvider user: ${authProvider.currentUser?.email}');
    print('DEBUG: Using user with photoUrl: ${user?.photoUrl?.substring(0, math.min(100, user.photoUrl?.length ?? 0)) ?? 'null'}');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const RaqimAppBar(
        title: 'الملف الشخصي',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  // Profile Image with Camera Icon
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.transparent,
                          child: _isUploading
                              ? const CircularProgressIndicator()
                              : _buildProfileImage(user),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _isUploading
                              ? null
                              : () => _showImageSourceDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // User Name
                  Text(
                    user?.name ?? 'المستخدم',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // User Type
                  Text(
                    'مشتري',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Settings Options
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: 'تعديل الملف الشخصي',
                    onTap: () => _showEditProfileDialog(context, user),
                  ),
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'الإشعارات',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // TODO: Implement notification settings
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // For web, use WebAuthService's signOut
                        if (kIsWeb && authService is WebAuthService) {
                          await authService.signOut();
                        } else {
                          // For mobile, use AuthProvider's logout
                          await authProvider.logout();
                        }

                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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