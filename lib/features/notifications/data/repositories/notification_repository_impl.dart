import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../../../../core/models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  
  NotificationRepositoryImpl({required NotificationRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;
  
  @override
  Future<List<Notification>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _remoteDataSource.getNotifications(
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
      await _remoteDataSource.markNotificationAsRead(notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
  
  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _remoteDataSource.markAllNotificationsAsRead();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }
  
  @override
  Future<int> getUnreadCount() async {
    try {
      return await _remoteDataSource.getUnreadCount();
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
  
  // Helper method to map model to entity
  Notification _mapModelToEntity(NotificationModel model) {
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
