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
      print('🔔 Fetching notifications: page=$page, limit=$limit, unreadOnly=$unreadOnly');
      
      final response = await _apiClient.getNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      );
      
      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          print('✅ API Success: Parsing notification data...');
          print('📋 Data structure: ${data['data']}');
          
          final notificationData = data['data'];
          if (notificationData != null) {
            print('✅ Notifications found: ${notificationData['notifications']?.length ?? 0} items');
            try {
              return NotificationListResponse.fromJson(notificationData);
            } catch (parseError) {
              print('❌ JSON Parse Error: $parseError');
              print('📋 Raw notification data: $notificationData');
              throw Exception('Failed to parse notification data: $parseError');
            }
          } else {
            print('❌ Invalid data structure: missing data field');
            throw Exception('Invalid response structure: missing data field');
          }
        } else {
          print('❌ API Error: ${data['error']}');
          throw Exception(data['error']?['message'] ?? 'Failed to fetch notifications');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to fetch notifications: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Network Error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      print('🔔 Marking notification as read: $notificationId');
      
      final response = await _apiClient.markNotificationAsRead(notificationId);
      
      print('📡 Mark as Read Response Status: ${response.statusCode}');
      print('📡 Mark as Read Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        print('✅ Notification marked as read successfully');
      } else {
        print('❌ Failed to mark notification as read: ${response.statusCode}');
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Network Error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error: $e');
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
      print('🔔 Fetching unread count...');
      
      final response = await _apiClient.getUnreadCount();
      
      print('📡 Unread Count Response Status: ${response.statusCode}');
      print('📡 Unread Count Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          try {
            final count = data['data']?['count'] ?? 0;
            print('✅ Unread count: $count');
            return count;
          } catch (parseError) {
            print('❌ Parse Error: $parseError');
            print('📋 Raw count data: ${data['data']}');
            return 0; // Return 0 as fallback
          }
        } else {
          print('❌ API Error: ${data['error']}');
          throw Exception(data['error']?['message'] ?? 'Failed to get unread count');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Network Error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
