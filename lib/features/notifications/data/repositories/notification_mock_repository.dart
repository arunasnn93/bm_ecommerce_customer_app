import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_mock_datasource.dart';

class NotificationMockRepository implements NotificationRepository {
  @override
  Future<List<Notification>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await NotificationMockDataSource.getNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      );
      
      return response.notifications.map((model) => _mapModelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }
  
  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await NotificationMockDataSource.markNotificationAsRead(notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
  
  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      await NotificationMockDataSource.markAllNotificationsAsRead();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }
  
  @override
  Future<int> getUnreadCount() async {
    try {
      return await NotificationMockDataSource.getUnreadCount();
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
  
  // Helper method to map model to entity
  Notification _mapModelToEntity(model) {
    return Notification(
      id: model.id,
      title: model.title,
      message: model.message,
      type: model.type,
      isRead: model.isRead,
      createdAt: model.createdAtDateTime,
      data: model.data,
    );
  }
}
