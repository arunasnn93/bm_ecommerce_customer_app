import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  });
  
  Future<void> markNotificationAsRead(String notificationId);
  
  Future<void> markAllNotificationsAsRead();
  
  Future<int> getUnreadCount();
}
