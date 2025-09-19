import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SimpleNotification extends StatefulWidget {
  final String title;
  final String message;
  final String type;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration autoHideDuration;

  const SimpleNotification({
    Key? key,
    required this.title,
    required this.message,
    this.type = 'info',
    this.onTap,
    this.onDismiss,
    this.autoHideDuration = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  State<SimpleNotification> createState() => _SimpleNotificationState();
}

class _SimpleNotificationState extends State<SimpleNotification> {
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _autoHideTimer = Timer(widget.autoHideDuration, () {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    super.dispose();
  }

  void dismiss() {
    _autoHideTimer?.cancel();
    widget.onDismiss?.call();
  }

  Color _getNotificationColor() {
    switch (widget.type) {
      case 'success':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'order_update':
        return AppColors.primary;
      default:
        return AppColors.info;
    }
  }

  IconData _getNotificationIcon() {
    switch (widget.type) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'order_update':
        return Icons.local_shipping;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onTap?.call();
            dismiss();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getNotificationIcon(),
                    color: _getNotificationColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.h6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Dismiss button
                GestureDetector(
                  onTap: dismiss,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleNotificationManager extends StatefulWidget {
  final Widget child;

  const SimpleNotificationManager({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SimpleNotificationManager> createState() => _SimpleNotificationManagerState();
}

class _SimpleNotificationManagerState extends State<SimpleNotificationManager> {
  final List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    // Add a test notification after 2 seconds to verify the system works
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _showTestNotification();
      }
    });
  }

  void _showTestNotification() {
    _showNotification(
      title: 'Test Notification',
      message: 'This is a test notification to verify the system works',
      type: 'info',
      onTap: () {
        print('Test notification tapped');
      },
    );
  }

  void _showNotification({
    required String title,
    required String message,
    String type = 'info',
    VoidCallback? onTap,
  }) {
    if (!mounted) return;

    final notificationItem = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      onTap: onTap,
    );

    setState(() {
      _notifications.add(notificationItem);
    });

    // Auto-remove after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _removeNotification(notificationItem.id);
      }
    });
  }

  void _removeNotification(String id) {
    if (!mounted) return;
    
    setState(() {
      _notifications.removeWhere((notification) => notification.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Show notifications at the top
        if (_notifications.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: _notifications.map((notificationItem) {
                return SimpleNotification(
                  key: ValueKey(notificationItem.id),
                  title: notificationItem.title,
                  message: notificationItem.message,
                  type: notificationItem.type,
                  onTap: notificationItem.onTap,
                  onDismiss: () => _removeNotification(notificationItem.id),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final VoidCallback? onTap;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.onTap,
  });
}
