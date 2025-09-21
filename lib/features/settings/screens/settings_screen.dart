import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/raqim_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<AppSettingsProvider>(context);
    final localizations = AppLocalizations.of(context);
    // Light mode only - dark mode removed as per requirements
    
    return Scaffold(
      appBar: const RaqimAppBar(
        title: 'الإعدادات',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section
              Text(
                localizations?.translate('language') ?? 'اللغة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildLanguageOption(
                      context,
                      title: 'العربية',
                      subtitle: 'Arabic',
                      isSelected: settingsProvider.isArabic,
                      onTap: () {
                        if (!settingsProvider.isArabic) {
                          settingsProvider.setLocale(const Locale('ar', 'SA'));
                        }
                      },
                      isFirst: true,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    _buildLanguageOption(
                      context,
                      title: 'English',
                      subtitle: 'الإنجليزية',
                      isSelected: !settingsProvider.isArabic,
                      onTap: () {
                        if (settingsProvider.isArabic) {
                          settingsProvider.setLocale(const Locale('en', 'US'));
                        }
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Notifications Section
              Text(
                localizations?.translate('notifications') ?? 'الإشعارات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[200]!,
                  ),
                ),
                child: _buildNotificationToggle(context, settingsProvider),
              ),
              const SizedBox(height: 32),

              // About Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.1),
                      AppColors.primaryColor.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 8),
                    Text(
                      settingsProvider.isArabic 
                          ? 'منصة الذكاء الاصطناعي العربية'
                          : 'Arabic AI Platform',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    // Light mode only - dark mode removed as per requirements
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primaryColor 
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primaryColor : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    AppSettingsProvider settingsProvider,
  ) {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.translate('enableNotifications') ?? 'تفعيل الإشعارات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizations?.translate('receiveNotificationsDescription') ??
                  'استلام إشعارات الدورات والتحديثات الجديدة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: settingsProvider.notificationsEnabled,
            onChanged: (value) {
              settingsProvider.toggleNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                      ? (localizations?.translate('notificationsEnabled') ?? 'تم تفعيل الإشعارات')
                      : (localizations?.translate('notificationsDisabled') ?? 'تم إلغاء تفعيل الإشعارات'),
                  ),
                  backgroundColor: AppColors.primaryColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            activeColor: AppColors.primaryColor,
            activeTrackColor: AppColors.primaryColor.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}