import '../../../../core/models/notification_model.dart';

class NotificationMockDataSource {
  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'Welcome to Beena Mart!',
      message: 'Thank you for joining us. Start exploring our amazing products.',
      type: 'welcome',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      data: {},
    ),
    NotificationModel(
      id: '2',
      title: 'New Products Available',
      message: 'Check out our latest collection of fresh vegetables and fruits.',
      type: 'product_update',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      data: {},
    ),
    NotificationModel(
      id: '3',
      title: 'Special Offer',
      message: 'Get 20% off on your first order. Use code WELCOME20',
      type: 'offer',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      data: {'discount_code': 'WELCOME20', 'discount_percentage': 20},
    ),
    NotificationModel(
      id: '4',
      title: 'Order Update',
      message: 'Your order #ORD-12345 has been confirmed and is being prepared.',
      type: 'order_status_change',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      data: {'order_id': 'ORD-12345', 'status': 'confirmed'},
    ),
    NotificationModel(
      id: '5',
      title: 'Delivery Scheduled',
      message: 'Your order will be delivered between 2:00 PM - 4:00 PM today.',
      type: 'delivery_update',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      data: {'delivery_time': '2:00 PM - 4:00 PM'},
    ),
  ];

  static Future<NotificationListResponse> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    List<NotificationModel> filteredNotifications = _mockNotifications;
    
    if (unreadOnly) {
      filteredNotifications = _mockNotifications.where((n) => !n.isRead).toList();
    }
    
    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedNotifications = filteredNotifications
        .skip(startIndex)
        .take(limit)
        .toList();
    
    return NotificationListResponse(
      notifications: paginatedNotifications,
      pagination: PaginationInfo(
        page: page,
        limit: limit,
        total: filteredNotifications.length,
        totalPages: (filteredNotifications.length / limit).ceil(),
        hasNext: endIndex < filteredNotifications.length,
        hasPrev: page > 1,
      ),
    );
  }
  
  static Future<void> markNotificationAsRead(String notificationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final notificationIndex = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (notificationIndex != -1) {
      _mockNotifications[notificationIndex] = NotificationModel(
        id: _mockNotifications[notificationIndex].id,
        title: _mockNotifications[notificationIndex].title,
        message: _mockNotifications[notificationIndex].message,
        type: _mockNotifications[notificationIndex].type,
        isRead: true,
        createdAt: _mockNotifications[notificationIndex].createdAt,
        data: _mockNotifications[notificationIndex].data,
      );
    }
  }
  
  static Future<void> markAllNotificationsAsRead() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    for (int i = 0; i < _mockNotifications.length; i++) {
      _mockNotifications[i] = NotificationModel(
        id: _mockNotifications[i].id,
        title: _mockNotifications[i].title,
        message: _mockNotifications[i].message,
        type: _mockNotifications[i].type,
        isRead: true,
        createdAt: _mockNotifications[i].createdAt,
        data: _mockNotifications[i].data,
      );
    }
  }
  
  static Future<int> getUnreadCount() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _mockNotifications.where((n) => !n.isRead).length;
  }
}
