import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import '../../auth/providers/auth_provider.dart';
import '../../../services/auth/auth_interface.dart';
import '../../../services/auth/web_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_settings_provider.dart';

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

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 16, right: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  // Dialog Methods
  void _showLanguageDialog(BuildContext context, AppSettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('اختر اللغة', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.language, color: AppColors.primaryColor),
              ),
              title: const Text('العربية'),
              trailing: provider.isArabic ? Icon(Icons.check, color: AppColors.primaryColor) : null,
              onTap: () {
                provider.setLocale(const Locale('ar', 'SA'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.language, color: AppColors.primaryColor),
              ),
              title: const Text('English'),
              trailing: !provider.isArabic ? Icon(Icons.check, color: AppColors.primaryColor) : null,
              onTap: () {
                provider.setLocale(const Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoSpeedDialog(BuildContext context, AppSettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('سرعة تشغيل الفيديو', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) =>
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.speed, color: AppColors.primaryColor),
              ),
              title: Text('${speed}x'),
              trailing: provider.videoSpeed == speed ? Icon(Icons.check, color: AppColors.primaryColor) : null,
              onTap: () {
                provider.setVideoSpeed(speed);
                Navigator.pop(context);
              },
            ),
          ).toList(),
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, AppSettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حجم الخط', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['small', 'medium', 'large', 'extra_large'].map((size) =>
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.text_fields, color: AppColors.primaryColor),
              ),
              title: Text(_getFontSizeLabel(size)),
              trailing: provider.fontSize == size ? Icon(Icons.check, color: AppColors.primaryColor) : null,
              onTap: () {
                provider.setFontSize(size);
                Navigator.pop(context);
              },
            ),
          ).toList(),
        ),
      ),
    );
  }

  void _showProfileVisibilityDialog(BuildContext context, AppSettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('رؤية الملف الشخصي', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.visibility, color: AppColors.primaryColor),
              ),
              title: const Text('عام - يمكن للجميع رؤيته'),
              trailing: provider.profileVisibility == 'public' ? Icon(Icons.check, color: AppColors.primaryColor) : null,
              onTap: () {
                provider.setProfileVisibility('public');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.visibility_off, color: AppColors.primaryColor),
              ),
              title: const Text('خاص - للأصدقاء فقط'),
              trailing: provider.profileVisibility == 'private' ? Icon(Icons.check, color: AppColors.primaryColor) : null,
              onTap: () {
                provider.setProfileVisibility('private');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRegionalContentDialog(BuildContext context, AppSettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('المحتوى الإقليمي', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['global', 'saudi', 'egypt', 'uae', 'other'].map((region) =>
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.public, color: AppColors.primaryColor),
              ),
              title: Text(_getRegionalContentLabel(region)),
              trailing: provider.regionalContent == region ? Icon(Icons.check, color: AppColors.primaryColor) : null,
              onTap: () {
                provider.setRegionalContent(region);
                Navigator.pop(context);
              },
            ),
          ).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('مسح التخزين المؤقت', textAlign: TextAlign.center),
        content: const Text('هل تريد مسح جميع الملفات المؤقتة؟ سيؤدي هذا إلى تحرير مساحة تخزين.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم مسح التخزين المؤقت'),
                  backgroundColor: AppColors.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            child: const Text('مسح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تصدير البيانات', textAlign: TextAlign.center),
        content: const Text('سيتم تصدير جميع بياناتك الشخصية وتقدمك في الدورات.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('جاري تصدير البيانات...'),
                  backgroundColor: AppColors.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            child: const Text('تصدير', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _getFontSizeLabel(String size) {
    switch (size) {
      case 'small': return 'صغير';
      case 'medium': return 'متوسط';
      case 'large': return 'كبير';
      case 'extra_large': return 'كبير جداً';
      default: return 'متوسط';
    }
  }

  String _getRegionalContentLabel(String region) {
    switch (region) {
      case 'global': return 'عالمي';
      case 'saudi': return 'السعودية';
      case 'egypt': return 'مصر';
      case 'uae': return 'الإمارات';
      case 'other': return 'أخرى';
      default: return 'عالمي';
    }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: !kIsWeb,
        leading: kIsWeb ? null : null,
        title: kIsWeb ? Text(
          'الملف الشخصي',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ) : Row(
          children: [
            SvgPicture.asset(
              'assets/images/raqimLogo.svg',
              height: 32,
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'الملف الشخصي',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[50],
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
                  // Profile Settings
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: 'تعديل الملف الشخصي',
                    onTap: () => _showEditProfileDialog(context, user),
                  ),

                  // Language Settings
                  _buildSectionTitle('اللغة'),
                  Consumer<AppSettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return _buildSettingItem(
                        icon: Icons.language,
                        title: 'اللغة',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              settingsProvider.isArabic ? 'العربية' : 'English',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right, color: Colors.grey[400]),
                          ],
                        ),
                        onTap: () => _showLanguageDialog(context, settingsProvider),
                      );
                    },
                  ),

                  // Learning & Course Settings
                  _buildSectionTitle('إعدادات التعلم والدورات'),
                  Consumer<AppSettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.play_circle_outline,
                            title: 'تشغيل تلقائي للدرس التالي',
                            trailing: Switch(
                              value: settingsProvider.autoPlayNext,
                              onChanged: settingsProvider.setAutoPlayNext,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.speed,
                            title: 'سرعة تشغيل الفيديو',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${settingsProvider.videoSpeed}x',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.grey[400]),
                              ],
                            ),
                            onTap: () => _showVideoSpeedDialog(context, settingsProvider),
                          ),
                          _buildSettingItem(
                            icon: Icons.save,
                            title: 'حفظ التقدم تلقائياً',
                            trailing: Switch(
                              value: settingsProvider.autoSaveProgress,
                              onChanged: settingsProvider.setAutoSaveProgress,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.download,
                            title: 'التحميل للمشاهدة بدون إنترنت',
                            trailing: Switch(
                              value: settingsProvider.offlineDownloads,
                              onChanged: settingsProvider.setOfflineDownloads,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Notification Settings
                  _buildSectionTitle('إعدادات الإشعارات'),
                  Consumer<AppSettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.notifications,
                            title: 'الإشعارات العامة',
                            trailing: Switch(
                              value: settingsProvider.notificationsEnabled,
                              onChanged: (value) => settingsProvider.toggleNotifications(),
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.schedule,
                            title: 'تذكيرات الدورات',
                            trailing: Switch(
                              value: settingsProvider.courseReminders,
                              onChanged: settingsProvider.setCourseReminders,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.assignment_late,
                            title: 'مواعيد التسليم',
                            trailing: Switch(
                              value: settingsProvider.assignmentDeadlines,
                              onChanged: settingsProvider.setAssignmentDeadlines,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.new_releases,
                            title: 'دورات جديدة',
                            trailing: Switch(
                              value: settingsProvider.newCourseAlerts,
                              onChanged: settingsProvider.setNewCourseAlerts,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Accessibility & Display
                  _buildSectionTitle('إمكانية الوصول والعرض'),
                  Consumer<AppSettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.text_fields,
                            title: 'حجم الخط',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getFontSizeLabel(settingsProvider.fontSize),
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.grey[400]),
                              ],
                            ),
                            onTap: () => _showFontSizeDialog(context, settingsProvider),
                          ),
                          _buildSettingItem(
                            icon: Icons.contrast,
                            title: 'التباين العالي',
                            trailing: Switch(
                              value: settingsProvider.highContrast,
                              onChanged: settingsProvider.setHighContrast,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.motion_photos_off,
                            title: 'تقليل الحركات',
                            trailing: Switch(
                              value: settingsProvider.reduceAnimations,
                              onChanged: settingsProvider.setReduceAnimations,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Privacy & Data
                  _buildSectionTitle('الخصوصية والبيانات'),
                  Consumer<AppSettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.visibility,
                            title: 'رؤية الملف الشخصي',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  settingsProvider.profileVisibility == 'public' ? 'عام' : 'خاص',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.grey[400]),
                              ],
                            ),
                            onTap: () => _showProfileVisibilityDialog(context, settingsProvider),
                          ),
                          _buildSettingItem(
                            icon: Icons.share,
                            title: 'مشاركة إحصائيات التعلم',
                            trailing: Switch(
                              value: settingsProvider.statisticsSharing,
                              onChanged: settingsProvider.setStatisticsSharing,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.wifi,
                            title: 'استخدام الواي فاي فقط',
                            trailing: Switch(
                              value: settingsProvider.wifiOnly,
                              onChanged: settingsProvider.setWifiOnly,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Account & Security
                  _buildSectionTitle('الحساب والأمان'),
                  Consumer<AppSettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.security,
                            title: 'المصادقة الثنائية',
                            trailing: Switch(
                              value: settingsProvider.twoFactorAuth,
                              onChanged: settingsProvider.setTwoFactorAuth,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.email,
                            title: 'رسائل البريد الإلكتروني',
                            trailing: Switch(
                              value: settingsProvider.emailPreferences,
                              onChanged: settingsProvider.setEmailPreferences,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.download,
                            title: 'تصدير البيانات',
                            onTap: () => _showExportDataDialog(context),
                          ),
                          _buildSettingItem(
                            icon: Icons.clear_all,
                            title: 'مسح التخزين المؤقت',
                            onTap: () => _showClearCacheDialog(context),
                          ),
                        ],
                      );
                    },
                  ),

                  // Regional Settings
                  _buildSectionTitle('الإعدادات الإقليمية'),
                  Consumer<AppSettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.access_time,
                            title: 'أوقات الصلاة',
                            trailing: Switch(
                              value: settingsProvider.prayerTimes,
                              onChanged: settingsProvider.setPrayerTimes,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.calendar_today,
                            title: 'التقويم الهجري',
                            trailing: Switch(
                              value: settingsProvider.hijriCalendar,
                              onChanged: settingsProvider.setHijriCalendar,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          _buildSettingItem(
                            icon: Icons.public,
                            title: 'المحتوى الإقليمي',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getRegionalContentLabel(settingsProvider.regionalContent),
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.grey[400]),
                              ],
                            ),
                            onTap: () => _showRegionalContentDialog(context, settingsProvider),
                          ),
                        ],
                      );
                    },
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