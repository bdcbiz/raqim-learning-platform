import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<AppSettingsProvider>(context);
    final localizations = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('settings') ?? 'الإعدادات'),
        centerTitle: true,
        elevation: 0,
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
                  color: isDarkMode 
                      ? Colors.grey[900] 
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode 
                        ? Colors.grey[800]! 
                        : Colors.grey[200]!,
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
                      color: isDarkMode 
                          ? Colors.grey[800] 
                          : Colors.grey[300],
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
              
              // Theme Section
              Text(
                localizations?.translate('theme') ?? 'المظهر',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.grey[900] 
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode 
                        ? Colors.grey[800]! 
                        : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildThemeOption(
                      context,
                      icon: Icons.light_mode,
                      title: localizations?.translate('lightMode') ?? 'الوضع الفاتح',
                      isSelected: settingsProvider.themeMode == ThemeMode.light,
                      onTap: () {
                        settingsProvider.setThemeMode(ThemeMode.light);
                      },
                      isFirst: true,
                    ),
                    Divider(
                      height: 1,
                      color: isDarkMode 
                          ? Colors.grey[800] 
                          : Colors.grey[300],
                    ),
                    _buildThemeOption(
                      context,
                      icon: Icons.dark_mode,
                      title: localizations?.translate('darkMode') ?? 'الوضع الداكن',
                      isSelected: settingsProvider.themeMode == ThemeMode.dark,
                      onTap: () {
                        settingsProvider.setThemeMode(ThemeMode.dark);
                      },
                    ),
                    Divider(
                      height: 1,
                      color: isDarkMode 
                          ? Colors.grey[800] 
                          : Colors.grey[300],
                    ),
                    _buildThemeOption(
                      context,
                      icon: Icons.settings_suggest,
                      title: localizations?.translate('systemTheme') ?? 'حسب النظام',
                      isSelected: settingsProvider.themeMode == ThemeMode.system,
                      onTap: () {
                        settingsProvider.setThemeMode(ThemeMode.system);
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // About Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'رقيم',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      settingsProvider.isArabic 
                          ? 'منصة الذكاء الاصطناعي العربية'
                          : 'Arabic AI Platform',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
                      ? AppTheme.primaryColor 
                      : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
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
                          color: AppTheme.primaryColor,
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
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
            Icon(
              icon,
              color: isSelected 
                  ? AppTheme.primaryColor 
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}