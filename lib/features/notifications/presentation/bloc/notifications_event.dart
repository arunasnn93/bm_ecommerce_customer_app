import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  final int page;
  final int limit;
  final bool unreadOnly;
  final bool refresh;

  const LoadNotifications({
    this.page = 1,
    this.limit = 20,
    this.unreadOnly = false,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, limit, unreadOnly, refresh];
}

class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationsEvent {
  const MarkAllNotificationsAsRead();
}

class RefreshNotifications extends NotificationsEvent {
  const RefreshNotifications();
}

class LoadUnreadCount extends NotificationsEvent {
  const LoadUnreadCount();
}
