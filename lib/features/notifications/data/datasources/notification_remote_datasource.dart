import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationListResponse> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  });
  
  Future<void> markNotificationAsRead(String notificationId);
  
  Future<void> markAllNotificationsAsRead();
  
  Future<int> getUnreadCount();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _apiClient;
  
  NotificationRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;
  
  @override
  Future<NotificationListResponse> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _apiClient.getNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final notificationData = data['data'];
          if (notificationData != null) {
            try {
              return NotificationListResponse.fromJson(notificationData);
            } catch (parseError) {
              throw Exception('Failed to parse notification data: $parseError');
            }
          } else {
            throw Exception('Invalid response structure: missing data field');
          }
        } else {
          throw Exception(data['error']?['message'] ?? 'Failed to fetch notifications');
        }
      } else {
        throw Exception('Failed to fetch notifications: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _apiClient.markNotificationAsRead(notificationId);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      final response = await _apiClient.markAllNotificationsAsRead();
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.getUnreadCount();
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          try {
            final count = data['data']?['count'] ?? 0;
            return count;
          } catch (parseError) {
            return 0; // Return 0 as fallback
          }
        } else {
          throw Exception(data['error']?['message'] ?? 'Failed to get unread count');
        }
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
