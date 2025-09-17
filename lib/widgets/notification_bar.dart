import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/theme/app_colors.dart';

class NotificationBar extends StatefulWidget {
  const NotificationBar({super.key});

  @override
  State<NotificationBar> createState() => _NotificationBarState();
}

class _NotificationBarState extends State<NotificationBar> {
  bool _isExpanded = false;
  bool _doNotDisturb = false;
  OverlayEntry? _overlayEntry;

  // Arabic notifications
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'تم تسجيلك في دورة جديدة: أساسيات البرمجة',
      message: '',
      time: DateTime.now(),
      type: NotificationType.course,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'تعليق جديد على منشورك في المجتمع',
      message: '',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.comment,
      isRead: false,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Overlay to close sidebar when tapping outside
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = false;
                });
                _removeOverlay();
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),

            // Notification Sidebar - moved to left side with circular design
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isExpanded ? 0 : -500,
              width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.9,
              child: Material(
                elevation: 16,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header with Do Not Disturb toggle - exact match
                      Container(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 60,
                          bottom: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(24),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'الإشعارات',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      // Notifications List - exact match to image
                      Expanded(
                        child: _notifications.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.notifications_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'لا توجد إشعارات',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: _notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = _notifications[index];
                                  return InkWell(
                                    onTap: () {
                                      _handleNotificationTap(notification);
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Purple dot indicator - exactly like image
                                          Container(
                                            width: 12,
                                            height: 12,
                                            margin: const EdgeInsets.only(top: 6),
                                            decoration: BoxDecoration(
                                              color: notification.isRead
                                                  ? Colors.grey[300]
                                                  : const Color(0xFF6C5CE7), // Purple from image
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          // Content - exact match
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notification.title,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: notification.isRead
                                                        ? FontWeight.w400
                                                        : FontWeight.w500,
                                                    color: Colors.black87,
                                                    height: 1.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  _formatTime(notification.time),
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Mark all as read button - exact match to image
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _markAllAsRead,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            child: const Text(
                              'تحديد الكل كمقروء',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: const Color(0xFF6C5CE7),
                size: 22,
              ),
              onPressed: () {
                if (_isExpanded) {
                  setState(() {
                    _isExpanded = false;
                  });
                  _removeOverlay();
                } else {
                  setState(() {
                    _isExpanded = true;
                  });
                  _showOverlay();
                }
              },
            ),
          ),
          if (_unreadCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}h ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 365) {
      if (difference.inDays < 30) {
        return '${difference.inDays}d ago';
      } else {
        // Format like "05 May 2019"
        final months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${time.day.toString().padLeft(2, '0')} ${months[time.month]} ${time.year}';
      }
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
      _isExpanded = false;
    });
    _removeOverlay();

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.course:
        // Navigator.pushNamed(context, '/courses');
        break;
      case NotificationType.comment:
        // Navigator.pushNamed(context, '/community');
        break;
      case NotificationType.certificate:
        // Navigator.pushNamed(context, '/certificates');
        break;
      case NotificationType.system:
        // Show system message
        break;
      case NotificationType.like:
        // Navigator.pushNamed(context, '/community');
        break;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });
}

enum NotificationType {
  course,
  comment,
  like,
  system,
  certificate,
}