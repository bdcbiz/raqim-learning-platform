import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/widgets/adaptive_logo.dart';

class ResponsiveAuthLayout extends StatelessWidget {
  final Widget form;
  final String title;
  final String subtitle;
  final bool showLogo;

  const ResponsiveAuthLayout({
    super.key,
    required this.form,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600 && size.width <= 900;
    final isMobile = size.width <= 600;
    final isWideScreen = size.width > 900;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Mobile Layout (Full Screen)
    if (isMobile) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode 
                ? [
                    AppTheme.primaryColor.withOpacity(0.2),
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    AppTheme.primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showLogo) ...[
                    const SizedBox(height: 40),
                    const Center(
                      child: AdaptiveLogo(height: 80),
                    ),
                    const SizedBox(height: 40),
                  ] else
                    const SizedBox(height: 20),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  form,
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Tablet Layout (Centered Card)
    if (isTablet) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.05),
                AppTheme.secondaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 500,
                margin: const EdgeInsets.all(32),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showLogo) ...[
                          const Center(
                            child: AdaptiveLogo(height: 80),
                          ),
                          const SizedBox(height: 32),
                        ],
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        form,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Desktop Layout (Split Screen)
    return Scaffold(
      body: Row(
        children: [
          // Logo and Description Section
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.secondaryColor,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AdaptiveLogo(
                      height: 120,
                      useWhiteVersion: true,
                    ),
                    const SizedBox(height: 32),
                    Consumer<AppSettingsProvider>(
                      builder: (context, settingsProvider, child) {
                        final localizations = AppLocalizations.of(context);
                        return Column(
                          children: [
                            Text(
                              localizations?.translate('yourPlatformForAI') ?? 'منصتك العربية الأولى\nللذكاء الاصطناعي',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                localizations?.translate('learnCreateExcel') ?? 'تعلم • ابتكر • تميز',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Form Section
          Expanded(
            flex: 4,
            child: Container(
              color: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : AppTheme.backgroundColor,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(48),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        form,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}