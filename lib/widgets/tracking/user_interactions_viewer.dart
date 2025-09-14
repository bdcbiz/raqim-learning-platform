import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/tracking/interaction_tracker.dart';
import '../../core/theme/app_theme.dart';

class UserInteractionsViewer extends StatefulWidget {
  const UserInteractionsViewer({super.key});

  @override
  State<UserInteractionsViewer> createState() => _UserInteractionsViewerState();
}

class _UserInteractionsViewerState extends State<UserInteractionsViewer> {
  final InteractionTracker _tracker = InteractionTracker();
  Map<String, dynamic>? _userStats;
  List<Map<String, dynamic>> _recentInteractions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInteractions();
  }

  Future<void> _loadInteractions() async {
    try {
      final stats = await _tracker.getUserStats();
      final interactions = await _tracker.getUserInteractions(limit: 20);

      if (mounted) {
        setState(() {
          _userStats = stats;
          _recentInteractions = interactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading interactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'غير محدد';

    try {
      if (timestamp is DateTime) {
        return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
      }
      // Handle Firestore Timestamp
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        final date = timestamp.toDate();
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
      return timestamp.toString();
    } catch (e) {
      return 'غير محدد';
    }
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'page_view':
        return 'عرض صفحة';
      case 'button_click':
        return 'نقرة زر';
      case 'course_view':
        return 'عرض دورة';
      case 'course_enroll':
        return 'التسجيل في دورة';
      case 'lesson_progress':
        return 'تقدم في الدرس';
      case 'search':
        return 'بحث';
      case 'login':
        return 'تسجيل دخول';
      case 'logout':
        return 'تسجيل خروج';
      case 'registration':
        return 'تسجيل حساب';
      case 'error':
        return 'خطأ';
      default:
        return action;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'page_view':
        return Icons.visibility;
      case 'button_click':
        return Icons.touch_app;
      case 'course_view':
      case 'course_enroll':
        return Icons.school;
      case 'lesson_progress':
        return Icons.trending_up;
      case 'search':
        return Icons.search;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'registration':
        return Icons.person_add;
      case 'error':
        return Icons.error;
      default:
        return Icons.analytics;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'error':
        return Colors.red;
      case 'registration':
      case 'login':
        return Colors.green;
      case 'course_enroll':
        return Colors.blue;
      case 'lesson_progress':
        return Colors.orange;
      default:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'نشاط المستخدم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadInteractions,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Cards
          if (_userStats != null) ...[
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'إجمالي التفاعلات',
                    value: _userStats!['totalInteractions'].toString(),
                    icon: Icons.analytics,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'أنواع الأنشطة',
                    value: (_userStats!['actionCounts'] as Map).length.toString(),
                    icon: Icons.category,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Recent Interactions
          const Text(
            'التفاعلات الأخيرة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (_recentInteractions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'لا توجد تفاعلات مسجلة بعد',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentInteractions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final interaction = _recentInteractions[index];
                final action = interaction['action'] ?? '';
                final details = interaction['details'] ?? {};
                final timestamp = interaction['timestamp'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActionColor(action).withValues(alpha: 0.1),
                    child: Icon(
                      _getActionIcon(action),
                      color: _getActionColor(action),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _getActionLabel(action),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (details['page'] != null)
                        Text('الصفحة: ${details['page']}'),
                      if (details['button'] != null)
                        Text('الزر: ${details['button']}'),
                      if (details['query'] != null)
                        Text('البحث: ${details['query']}'),
                      if (details['courseId'] != null)
                        Text('معرف الدورة: ${details['courseId']}'),
                      if (details['progress'] != null)
                        Text('التقدم: ${details['progress']}%'),
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: details['platform'] != null
                      ? Icon(
                          details['platform'] == 'web'
                              ? Icons.web
                              : Icons.phone_android,
                          size: 16,
                          color: Colors.grey,
                        )
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}