import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive_theme.dart';
import '../notification_bar.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final String? userAvatarUrl;
  final VoidCallback? onAvatarTap;

  const WelcomeHeader({
    super.key,
    required this.userName,
    this.userAvatarUrl,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.inputBackground,
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: userAvatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        userAvatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                      ),
                    )
                  : _buildAvatarPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          
          // Welcome Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً، $userName',
                  style: ResponsiveAppTextStyles.h2(context),
                ),
                Text(
                  'ماذا تود أن تتعلم اليوم؟',
                  style: ResponsiveAppTextStyles.bodySmall(context),
                ),
              ],
            ),
          ),
          
          // Notification Bar
          const NotificationBar(),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Icon(
      Icons.person,
      size: 24,
      color: AppColors.secondaryText,
    );
  }
}