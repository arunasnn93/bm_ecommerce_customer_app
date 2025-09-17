class Notification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.data,
  });

  // Helper methods
  bool get isOrderStatusChange => type == 'order_status_change';
  bool get isAdminMessage => type == 'admin_message';
  bool get isPriceUpdate => type == 'price_update';
  bool get isSystemUpdate => type == 'system_update';
  
  String? get orderId => data['order_id'];
  String? get status => data['status'];
  double? get newPrice => data['new_price']?.toDouble();
  
  // Get notification icon based on type
  String get iconName {
    switch (type) {
      case 'order_status_change':
        return 'shopping_cart';
      case 'admin_message':
        return 'message';
      case 'price_update':
        return 'attach_money';
      case 'system_update':
        return 'system_update';
      default:
        return 'notifications';
    }
  }
  
  // Get notification color based on type
  String get colorHex {
    switch (type) {
      case 'order_status_change':
        return '#2196F3'; // Blue
      case 'admin_message':
        return '#4CAF50'; // Green
      case 'price_update':
        return '#FF9800'; // Orange
      case 'system_update':
        return '#9C27B0'; // Purple
      default:
        return '#607D8B'; // Blue Grey
    }
  }
}
