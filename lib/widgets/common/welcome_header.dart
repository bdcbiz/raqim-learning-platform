import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final String? userAvatarUrl;
  final VoidCallback? onAvatarTap;

  const WelcomeHeader({
    Key? key,
    required this.userName,
    this.userAvatarUrl,
    this.onAvatarTap,
  }) : super(key: key);

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
                  color: AppColors.primaryColor.withOpacity(0.2),
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
                  style: AppTextStyles.h2,
                ),
                Text(
                  'ماذا تود أن تتعلم اليوم؟',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          
          // Notification Icon
          IconButton(
            onPressed: () {
              // Handle notifications
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.secondaryText,
            ),
          ),
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