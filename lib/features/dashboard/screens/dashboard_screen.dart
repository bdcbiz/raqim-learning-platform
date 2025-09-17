import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/screens/courses_list_screen.dart';
import '../../community/screens/community_feed_screen.dart';
import '../../news/screens/news_feed_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/adaptive_logo.dart';
import '../../../services/analytics/analytics_service_factory.dart';
import 'modern_home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const ModernHomeScreen(),
    const CoursesListScreen(showOnlyEnrolled: true), // Show only enrolled courses
    const CommunityFeedScreen(),
    const NewsFeedScreen(),
    const ProfileScreen(),
  ];

  List<NavigationDestination> _destinations(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return [
      NavigationDestination(
        icon: Icon(Icons.home_outlined, color: Color(0xFFB8B2E8)),
        selectedIcon: Icon(Icons.home, color: Color(0xFFE8E5FF)),
        label: localizations?.translate('home') ?? 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.school_outlined, color: Color(0xFFB8B2E8)),
        selectedIcon: Icon(Icons.school, color: Color(0xFFE8E5FF)),
        label: localizations?.translate('myCourses') ?? 'My Courses',
      ),
      NavigationDestination(
        icon: Icon(Icons.forum_outlined, color: Color(0xFFB8B2E8)),
        selectedIcon: Icon(Icons.forum, color: Color(0xFFE8E5FF)),
        label: localizations?.translate('community') ?? 'Community',
      ),
      NavigationDestination(
        icon: Icon(Icons.newspaper_outlined, color: Color(0xFFB8B2E8)),
        selectedIcon: Icon(Icons.newspaper, color: Color(0xFFE8E5FF)),
        label: localizations?.translate('news') ?? 'News',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined, color: Color(0xFFB8B2E8)),
        selectedIcon: Icon(Icons.settings, color: Color(0xFFE8E5FF)),
        label: 'الإعدادات',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 900;
    
    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.of(context).size.width > 1200,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) async {
                setState(() {
                  _selectedIndex = index;
                });
                await _trackNavigation(index);
              },
              labelType: NavigationRailLabelType.none,
              backgroundColor: AppColors.primaryColor,
              selectedIconTheme: const IconThemeData(
                color: Color(0xFFE8E5FF),
                size: 28,
              ),
              unselectedIconTheme: const IconThemeData(
                color: Color(0xFFB8B2E8),
                size: 24,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFFE8E5FF),
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Color(0xFFB8B2E8),
              ),
              indicatorColor: Color(0xFFE8E5FF).withValues(alpha: 0.3),
              leading: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AdaptiveLogo(height: 32, useWhiteVersion: true),
                  ],
                ),
              ),
              destinations: _destinations(context).map((dest) => NavigationRailDestination(
                icon: dest.icon,
                selectedIcon: dest.selectedIcon,
                label: Text(dest.label),
              )).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const AdaptiveLogo(height: 32),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      extendBody: false,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) async {
          setState(() {
            _selectedIndex = index;
          });
          await _trackNavigation(index);
        },
        destinations: _destinations(context),
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primaryColor.withValues(alpha: 0.1),
        surfaceTintColor: AppColors.white,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 65,
      ),
    );
  }

  Future<void> _trackNavigation(int index) async {
    final analytics = AnalyticsServiceFactory.instance;
    final screenNames = ['home', 'my_courses', 'community', 'news', 'profile'];

    if (index < screenNames.length) {
      await analytics.setCurrentScreen(
        screenName: 'dashboard_${screenNames[index]}',
        screenClass: 'DashboardScreen',
      );

      await analytics.logEvent('navigation_tap', {
        'destination': screenNames[index],
        'from_screen': 'dashboard',
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initAnalytics();
  }

  Future<void> _initAnalytics() async {
    final analytics = AnalyticsServiceFactory.instance;
    await analytics.setCurrentScreen(
      screenName: 'dashboard_home',
      screenClass: 'DashboardScreen',
    );
  }
}

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('appTitle') ?? 'Raqim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: AppLocalizations.of(context)?.translate('settings') ?? 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: AppLocalizations.of(context)?.translate('notifications') ?? 'Notifications',
          ),
          if (isWideScreen) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(AppLocalizations.of(context)?.translate('logout') ?? 'Logout'),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryColor,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppLocalizations.of(context)?.translate('welcome') ?? 'Welcome'}, ${user?.name ?? AppLocalizations.of(context)?.translate('user') ?? 'User'}!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)?.translate('readyToLearn') ?? 'Ready to learn something new today?',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions Section
            Text(
              AppLocalizations.of(context)?.translate('quickActions') ?? 'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to courses directly
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CoursesListScreen()),
                      );
                    },
                    icon: const Icon(Icons.school),
                    label: Text(AppLocalizations.of(context)?.translate('exploreCourses') ?? 'Explore Courses'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/my-courses'),
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(AppLocalizations.of(context)?.translate('myCourses') ?? 'My Courses'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/certificates'),
                    icon: const Icon(Icons.workspace_premium),
                    label: Text(AppLocalizations.of(context)?.translate('myCertificates') ?? 'My Certificates'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.translate('statistics') ?? 'Statistics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isWideScreen ? 4 : 2,
              childAspectRatio: MediaQuery.of(context).size.width < 360 ? 1.3 : 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                InkWell(
                  onTap: () => context.go('/my-courses'),
                  child: _buildStatCard(
                    context,
                    AppLocalizations.of(context)?.translate('enrolledCourses') ?? 'Enrolled Courses',
                    '3',
                    Icons.school,
                    Colors.blue,
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/my-courses'),
                  child: _buildStatCard(
                    context,
                    AppLocalizations.of(context)?.translate('completedCourses') ?? 'Completed Courses',
                    '2',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                _buildStatCard(
                  context,
                  AppLocalizations.of(context)?.translate('points') ?? 'Points',
                  '250',
                  Icons.star,
                  Colors.orange,
                ),
                InkWell(
                  onTap: () => context.go('/certificates'),
                  child: _buildStatCard(
                    context,
                    AppLocalizations.of(context)?.translate('certificates') ?? 'Certificates',
                    '2',
                    Icons.workspace_premium,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)?.translate('recentActivities') ?? 'Recent Activities',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final localizations = AppLocalizations.of(context);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        index % 2 == 0 ? Icons.play_circle : Icons.comment,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    title: Text(
                      index % 2 == 0
                          ? '${localizations?.translate('watchedLesson') ?? 'شاهدت درس'} "${localizations?.translate('introToMachineLearning') ?? 'مقدمة في تعلم الآلة'}"'
                          : localizations?.translate('commentedOnPost') ?? 'علقت على منشور في المجتمع',
                    ),
                    subtitle: Text(
                      index == 0 
                          ? localizations?.translate('sinceHour') ?? 'منذ ساعة'
                          : '${localizations?.translate('since') ?? 'منذ'} ${index + 1} ${localizations?.translate('sinceHours') ?? 'ساعات'}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}