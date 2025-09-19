import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/socket_service.dart';

class FloatingNotification extends StatefulWidget {
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration autoHideDuration;

  const FloatingNotification({
    Key? key,
    required this.title,
    required this.message,
    this.type = 'info',
    this.data,
    this.onTap,
    this.onDismiss,
    this.autoHideDuration = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  State<FloatingNotification> createState() => _FloatingNotificationState();
}

class _FloatingNotificationState extends State<FloatingNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();

    // Auto hide timer
    _autoHideTimer = Timer(widget.autoHideDuration, () {
      dismiss();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _autoHideTimer?.cancel();
    super.dispose();
  }

  void dismiss() {
    _autoHideTimer?.cancel();
    _slideController.reverse().then((_) {
      widget.onDismiss?.call();
    });
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
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
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
            ),
          ),
        );
      },
    );
  }
}

class FloatingNotificationManager extends StatefulWidget {
  final Widget child;

  const FloatingNotificationManager({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<FloatingNotificationManager> createState() => _FloatingNotificationManagerState();
}

class _FloatingNotificationManagerState extends State<FloatingNotificationManager> {
  final List<FloatingNotificationData> _notifications = [];
  final SocketService _socketService = SocketService();
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _orderUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    // Listen to notification stream
    _notificationSubscription = _socketService.notificationStream.listen((notification) {
      _showNotification(
        title: notification['title'] ?? 'Notification',
        message: notification['message'] ?? '',
        type: notification['type'] ?? 'info',
        data: notification['data'],
        onTap: () {
          _handleNotificationTap(notification);
        },
      );
    });

    // Listen to order update stream
    _orderUpdateSubscription = _socketService.orderUpdateStream.listen((orderUpdate) {
      _showNotification(
        title: 'Order Update',
        message: orderUpdate['message'] ?? 'Your order has been updated',
        type: 'order_update',
        data: orderUpdate['data'],
        onTap: () {
          _handleOrderUpdateTap(orderUpdate);
        },
      );
    });
  }

  void _showNotification({
    required String title,
    required String message,
    String type = 'info',
    Map<String, dynamic>? data,
    VoidCallback? onTap,
  }) {
    final notificationData = FloatingNotificationData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      data: data,
      onTap: onTap,
    );

    setState(() {
      _notifications.add(notificationData);
    });

    // Auto-remove after 5 seconds
    Timer(const Duration(seconds: 5), () {
      _removeNotification(notificationData.id);
    });
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications.removeWhere((notification) => notification.id == id);
    });
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Handle different types of notifications
    final type = notification['type'];
    final data = notification['data'];

    switch (type) {
      case 'order_update':
        _handleOrderUpdateTap(notification);
        break;
      case 'offer':
        // Navigate to offers page
        break;
      case 'system_update':
        // Navigate to notifications page
        break;
      default:
        // Default action
        break;
    }
  }

  void _handleOrderUpdateTap(Map<String, dynamic> orderUpdate) {
    final orderId = orderUpdate['data']?['orderId'];
    if (orderId != null) {
      // Navigate to order details or track order page
      Navigator.of(context).pushNamed('/track-order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Show notifications at the top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: _notifications.map((notificationData) {
              return FloatingNotification(
                key: ValueKey(notificationData.id),
                title: notificationData.title,
                message: notificationData.message,
                type: notificationData.type,
                data: notificationData.data,
                onTap: notificationData.onTap,
                onDismiss: () => _removeNotification(notificationData.id),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _orderUpdateSubscription?.cancel();
    super.dispose();
  }
}

class FloatingNotificationData {
  final String id;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final VoidCallback? onTap;

  FloatingNotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    this.onTap,
  });
}