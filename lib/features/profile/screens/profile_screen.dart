import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import 'dart:math' as Math;
import '../../auth/providers/auth_provider.dart';
import '../../../services/auth/auth_interface.dart';
import '../../../services/auth/web_auth_service.dart';
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
                      color: AppColors.primaryColor.withOpacity(0.1),
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
                        color: AppColors.primaryColor.withOpacity(0.1),
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
    print('DEBUG: user photoUrl: ${user?.photoUrl?.substring(0, 100) ?? 'null'}');

    if (user?.photoUrl != null && user.photoUrl.isNotEmpty) {
      // Check if it's a data URL (for web)
      if (user.photoUrl.startsWith('data:')) {
        try {
          print('DEBUG: Processing base64 image');
          // Extract the base64 part from the data URL
          final base64String = user.photoUrl.split(',')[1];
          final imageBytes = base64Decode(base64String);
          print('DEBUG: Decoded ${imageBytes.length} bytes');

          return ClipOval(
            child: Image.memory(
              imageBytes,
              width: 96,
              height: 96,
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
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 96,
                height: 96,
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
            width: 96,
            height: 96,
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
    // Try to get user from WebAuthService first (for web)
    final authService = Provider.of<AuthServiceInterface>(context);
    final webUser = authService.currentUser;

    // Fallback to AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = webUser ?? authProvider.currentUser;

    print('DEBUG: Profile build - webUser: ${webUser?.email}, authProvider user: ${authProvider.currentUser?.email}');
    print('DEBUG: Using user with photoUrl: ${user?.photoUrl?.substring(0, Math.min(100, user.photoUrl?.length ?? 0)) ?? 'null'}');

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
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.7),
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
                            color: AppColors.primaryColor,
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