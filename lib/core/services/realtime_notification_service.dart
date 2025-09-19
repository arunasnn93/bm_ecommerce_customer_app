import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/notification_model.dart';

/// Service for handling real-time notifications using Supabase
class RealtimeNotificationService {
  static RealtimeNotificationService? _instance;
  static RealtimeNotificationService get instance => _instance ??= RealtimeNotificationService._();
  
  RealtimeNotificationService._();
  
  SupabaseClient? _supabase;
  RealtimeChannel? _channel;
  StreamController<NotificationModel>? _notificationStreamController;
  StreamController<int>? _unreadCountStreamController;
  
  /// Stream for new notifications
  Stream<NotificationModel> get notificationStream => 
    _notificationStreamController?.stream ?? const Stream.empty();
  
  /// Stream for unread count updates
  Stream<int> get unreadCountStream => 
    _unreadCountStreamController?.stream ?? const Stream.empty();
  
  /// Initialize the real-time service
  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Initialize Supabase client
        _supabase = Supabase.instance.client;
        
        // Test Supabase connection
        if (_supabase != null) {
          // Create stream controllers
          _notificationStreamController = StreamController<NotificationModel>.broadcast();
          _unreadCountStreamController = StreamController<int>.broadcast();
        } else {
          return;
        }
      } else {
        // Realtime notifications only supported on web platform
      }
    } catch (e) {
      // Error initializing Realtime Notification Service
    }
  }
  
  /// Start listening for real-time notifications
  Future<void> startListening(String userId) async {
    try {
      if (_supabase == null) {
        return;
      }
      
      if (_channel != null) {
        await stopListening();
      }
      
      // Create a channel for notifications
      _channel = _supabase!.channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _handleNewNotification,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _handleNotificationUpdate,
        )
        .subscribe((status, error) {
          // Handle subscription status
        });
      
    } catch (e) {
      // Error starting real-time listener
    }
  }
  
  /// Handle new notification insertion
  void _handleNewNotification(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      if (newRecord != null) {
        final notification = NotificationModel.fromJson(newRecord);
        
        // Add to stream
        _notificationStreamController?.add(notification);
        
        // Update unread count (increment by 1)
        _updateUnreadCount(1);
      }
    } catch (e) {
      // Error handling new notification
    }
  }
  
  /// Handle notification updates (e.g., marked as read)
  void _handleNotificationUpdate(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      final oldRecord = payload.oldRecord;
      
      if (newRecord != null && oldRecord != null) {
        final wasRead = oldRecord['is_read'] as bool? ?? false;
        final isNowRead = newRecord['is_read'] as bool? ?? false;
        
        // If notification was just marked as read, decrement unread count
        if (!wasRead && isNowRead) {
          _updateUnreadCount(-1);
        }
        // If notification was unmarked as read, increment unread count
        else if (wasRead && !isNowRead) {
          _updateUnreadCount(1);
        }
      }
    } catch (e) {
      // Error handling notification update
    }
  }
  
  /// Update unread count
  void _updateUnreadCount(int delta) {
    // This is a simplified approach - in a real app you might want to
    // fetch the actual count from the server
    _unreadCountStreamController?.add(delta);
  }
  
  /// Stop listening for real-time notifications
  Future<void> stopListening() async {
    try {
      if (_channel != null) {
        await _supabase?.removeChannel(_channel!);
        _channel = null;
      }
    } catch (e) {
      // Error stopping real-time listener
    }
  }
  
  /// Dispose resources
  void dispose() {
    stopListening();
    _notificationStreamController?.close();
    _unreadCountStreamController?.close();
    _notificationStreamController = null;
    _unreadCountStreamController = null;
  }
}
