import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<Notification> notifications;
  final int unreadCount;
  final bool hasMore;
  final int currentPage;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore, currentPage];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotificationMarkedAsRead extends NotificationsState {
  final String notificationId;
  final int newUnreadCount;

  const NotificationMarkedAsRead({
    required this.notificationId,
    required this.newUnreadCount,
  });

  @override
  List<Object?> get props => [notificationId, newUnreadCount];
}

class AllNotificationsMarkedAsRead extends NotificationsState {
  const AllNotificationsMarkedAsRead();
}

class UnreadCountLoaded extends NotificationsState {
  final int count;

  const UnreadCountLoaded({required this.count});

  @override
  List<Object?> get props => [count];
}
