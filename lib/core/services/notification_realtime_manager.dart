import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notification_model.dart';
import 'realtime_notification_service.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_event.dart';

/// Manager that connects real-time notification streams to the NotificationsBloc
class NotificationRealtimeManager {
  static NotificationRealtimeManager? _instance;
  static NotificationRealtimeManager get instance => _instance ??= NotificationRealtimeManager._();
  
  NotificationRealtimeManager._();
  
  StreamSubscription<NotificationModel>? _notificationSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  NotificationsBloc? _notificationsBloc;
  
  /// Start listening for real-time notifications and connect to BLoC
  void startListening(NotificationsBloc notificationsBloc, String userId) {
    try {
      _notificationsBloc = notificationsBloc;
      
      // Start Supabase real-time listener
      RealtimeNotificationService.instance.startListening(userId);
      
      // Listen to new notifications stream
      _notificationSubscription = RealtimeNotificationService.instance.notificationStream.listen(
        (notification) {
          _notificationsBloc?.add(NewNotificationReceived(notification: notification));
        },
        onError: (error) {
          // Error in notification stream
        },
      );
      
      // Listen to unread count updates
      _unreadCountSubscription = RealtimeNotificationService.instance.unreadCountStream.listen(
        (delta) {
          _notificationsBloc?.add(UnreadCountUpdated(delta: delta));
        },
        onError: (error) {
          // Error in unread count stream
        },
      );
      
    } catch (e) {
      // Error starting Notification Realtime Manager
    }
  }
  
  /// Stop listening for real-time notifications
  Future<void> stopListening() async {
    try {
      // Cancel subscriptions
      await _notificationSubscription?.cancel();
      await _unreadCountSubscription?.cancel();
      
      // Stop Supabase real-time listener
      await RealtimeNotificationService.instance.stopListening();
      
      _notificationSubscription = null;
      _unreadCountSubscription = null;
      _notificationsBloc = null;
    } catch (e) {
      // Error stopping Notification Realtime Manager
    }
  }
  
  /// Dispose resources
  void dispose() {
    stopListening();
    RealtimeNotificationService.instance.dispose();
  }
}
