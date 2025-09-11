import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isRead;
  final String? actionUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.actionUrl,
  });
}

enum NotificationType {
  course,
  achievement,
  announcement,
  reminder,
  system
}

class NotificationSidebar extends StatefulWidget {
  final VoidCallback onClose;
  final bool isVisible;

  const NotificationSidebar({
    super.key,
    required this.onClose,
    required this.isVisible,
  });

  @override
  State<NotificationSidebar> createState() => _NotificationSidebarState();
}

class _NotificationSidebarState extends State<NotificationSidebar> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'دورة جديدة متاحة',
      message: 'تم إضافة دورة "تطوير تطبيقات الويب" إلى القسم البرمجي',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.course,
    ),
    NotificationItem(
      id: '2',
      title: 'إنجاز جديد',
      message: 'مبروك! لقد أكملت 5 دورات هذا الشهر',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.achievement,
      isRead: true,
    ),
    NotificationItem(
      id: '3',
      title: 'تذكير',
      message: 'لديك درس غير مكتمل في دورة "أساسيات البرمجة"',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.reminder,
    ),
    NotificationItem(
      id: '4',
      title: 'إعلان مهم',
      message: 'ستبدأ فترة التخفيضات الشتوية غداً بخصم يصل إلى 50%',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.announcement,
    ),
    NotificationItem(
      id: '5',
      title: 'تحديث النظام',
      message: 'تم تحديث المنصة بميزات جديدة',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.system,
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(NotificationSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.course:
        return Icons.school;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.course:
        return Colors.blue;
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.announcement:
        return Colors.purple;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Visibility(
          visible: _controller.value > 0,
          child: Stack(
            children: [
              // Backdrop
              if (_controller.value > 0)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      color: Colors.black.withOpacity(0.5 * _controller.value),
                    ),
                  ),
                ),
              // Sidebar
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: sidebarWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(-2, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    localizations?.translate('notifications') ?? 'الإشعارات',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: widget.onClose,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Actions Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  // Mark all as read
                                },
                                icon: const Icon(Icons.done_all, size: 18),
                                label: const Text('تحديد الكل كمقروء'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryColor,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // Clear all
                                },
                                icon: const Icon(Icons.clear_all, size: 18),
                                label: const Text('مسح الكل'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notifications List
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _notifications.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return Material(
                                color: notification.isRead 
                                    ? Colors.white 
                                    : AppColors.primaryColor.withOpacity(0.05),
                                child: InkWell(
                                  onTap: () {
                                    // Handle notification tap
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Icon
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _getNotificationColor(notification.type)
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            _getNotificationIcon(notification.type),
                                            size: 20,
                                            color: _getNotificationColor(notification.type),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      notification.title,
                                                      style: TextStyle(
                                                        fontWeight: notification.isRead 
                                                            ? FontWeight.normal 
                                                            : FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  if (!notification.isRead)
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primaryColor,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                notification.message,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatTime(notification.time),
                                                style: TextStyle(
                                                  fontSize: 11,
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
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}