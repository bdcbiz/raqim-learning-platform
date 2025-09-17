import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/admin_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/stats_card.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check authentication and load dashboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminAuth = context.read<AdminAuthProvider>();
      if (!adminAuth.isAuthenticated) {
        // If not authenticated, redirect to admin login
        context.go('/admin-login');
        return;
      }
      context.read<AdminProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Consumer<AdminAuthProvider>(
      builder: (context, adminAuth, child) {
        // If not authenticated, show loading or redirect
        if (!adminAuth.isAuthenticated) {
          // This will be handled by initState redirect, but show loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Sidebar for desktop
          if (isDesktop)
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                _navigateToSection(index);
              },
            ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      if (!isDesktop)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      const SizedBox(width: 16),
                      Text(
                        'لوحة التحكم الإدارية',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      // Admin profile
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryColor,
                              child: const Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'المدير',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Consumer<AdminProvider>(
                      builder: (context, adminProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Statistics Cards
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: isDesktop ? 1.5 : 2,
                              children: [
                                StatsCard(
                                  title: 'إجمالي المستخدمين',
                                  value: adminProvider.totalUsers.toString(),
                                  icon: Icons.people,
                                  color: Colors.blue,
                                  change: '+12%',
                                  isPositive: true,
                                ),
                                StatsCard(
                                  title: 'إجمالي الدورات',
                                  value: adminProvider.totalCourses.toString(),
                                  icon: Icons.school,
                                  color: Colors.green,
                                  change: '+5%',
                                  isPositive: true,
                                ),
                                StatsCard(
                                  title: 'إجمالي التسجيلات',
                                  value: adminProvider.totalEnrollments.toString(),
                                  icon: Icons.assignment,
                                  color: Colors.orange,
                                  change: '+18%',
                                  isPositive: true,
                                ),
                                StatsCard(
                                  title: 'إجمالي الإيرادات',
                                  value: '\$${adminProvider.totalRevenue.toStringAsFixed(2)}',
                                  icon: Icons.attach_money,
                                  color: Colors.purple,
                                  change: '+23%',
                                  isPositive: true,
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Charts Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User Registration Chart
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 400,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'تسجيلات المستخدمين الجدد (آخر 30 يوم)',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Expanded(
                                          child: LineChart(
                                            LineChartData(
                                              gridData: FlGridData(show: false),
                                              titlesData: FlTitlesData(
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 40,
                                                  ),
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 30,
                                                  ),
                                                ),
                                                rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(showTitles: false),
                                                ),
                                                topTitles: AxisTitles(
                                                  sideTitles: SideTitles(showTitles: false),
                                                ),
                                              ),
                                              borderData: FlBorderData(show: false),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: adminProvider.userRegistrationData,
                                                  isCurved: true,
                                                  color: AppColors.primaryColor,
                                                  barWidth: 3,
                                                  dotData: FlDotData(show: false),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 24),

                                // Popular Courses Chart
                                if (isDesktop)
                                  Expanded(
                                    child: Container(
                                      height: 400,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'الدورات الأكثر شعبية',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Expanded(
                                            child: BarChart(
                                              BarChartData(
                                                alignment: BarChartAlignment.spaceAround,
                                                maxY: 100,
                                                barTouchData: BarTouchData(enabled: false),
                                                titlesData: FlTitlesData(
                                                  show: true,
                                                  bottomTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      getTitlesWidget: (value, meta) {
                                                        final courses = adminProvider.popularCourses;
                                                        if (value.toInt() < courses.length) {
                                                          return Padding(
                                                            padding: const EdgeInsets.only(top: 8),
                                                            child: Text(
                                                              courses[value.toInt()]['name'] ?? '',
                                                              style: const TextStyle(fontSize: 10),
                                                            ),
                                                          );
                                                        }
                                                        return const Text('');
                                                      },
                                                      reservedSize: 40,
                                                    ),
                                                  ),
                                                  leftTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      reservedSize: 40,
                                                    ),
                                                  ),
                                                  topTitles: AxisTitles(
                                                    sideTitles: SideTitles(showTitles: false),
                                                  ),
                                                  rightTitles: AxisTitles(
                                                    sideTitles: SideTitles(showTitles: false),
                                                  ),
                                                ),
                                                borderData: FlBorderData(show: false),
                                                barGroups: adminProvider.popularCoursesData,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Recent Activity
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'النشاط الأخير',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...adminProvider.recentActivities.map((activity) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: _getActivityColor(activity['type']),
                                        child: Icon(
                                          _getActivityIcon(activity['type']),
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(activity['message'] ?? ''),
                                      subtitle: Text(activity['time'] ?? ''),
                                      trailing: activity['type'] == 'payment'
                                          ? Text(
                                              '\$${activity['amount'] ?? '0'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            )
                                          : null,
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isDesktop
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.pop(context);
                  _navigateToSection(index);
                },
              ),
            )
          : null,
        );
      },
    );
  }

  void _navigateToSection(int index) {
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        context.go('/admin/courses');
        break;
      case 2:
        context.go('/admin/users');
        break;
      case 3:
        context.go('/admin/content');
        break;
      case 4:
        context.go('/admin/finance');
        break;
      case 5:
        context.go('/admin/settings');
        break;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'enrollment':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'course':
        return Colors.orange;
      case 'user':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'enrollment':
        return Icons.assignment;
      case 'payment':
        return Icons.payment;
      case 'course':
        return Icons.school;
      case 'user':
        return Icons.person_add;
      default:
        return Icons.info;
    }
  }
}