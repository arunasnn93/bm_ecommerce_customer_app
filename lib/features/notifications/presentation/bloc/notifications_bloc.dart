import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;

  NotificationsBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationReadUseCase markNotificationReadUseCase,
    required MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase,
    required GetUnreadCountUseCase getUnreadCountUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _markNotificationReadUseCase = markNotificationReadUseCase,
        _markAllNotificationsReadUseCase = markAllNotificationsReadUseCase,
        _getUnreadCountUseCase = getUnreadCountUseCase,
        super(const NotificationsInitial()) {
    
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (event.refresh || state is NotificationsInitial) {
        emit(const NotificationsLoading());
      }

      final notifications = await _getNotificationsUseCase(
        GetNotificationsParams(
          page: event.page,
          limit: event.limit,
          unreadOnly: event.unreadOnly,
        ),
      );

      final unreadCount = await _getUnreadCountUseCase(NoParams());

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        hasMore: notifications.length == event.limit,
        currentPage: event.page,
      ));
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _markNotificationReadUseCase(event.notificationId);

      // Refresh notifications to show updated read status
      final notifications = await _getNotificationsUseCase(
        GetNotificationsParams(
          page: 1,
          limit: 20,
          unreadOnly: false,
        ),
      );

      // Update unread count
      final unreadCount = await _getUnreadCountUseCase(NoParams());

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        hasMore: notifications.length == 20,
        currentPage: 1,
      ));
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _markAllNotificationsReadUseCase(NoParams());

      // Refresh notifications to show updated read status
      final notifications = await _getNotificationsUseCase(
        GetNotificationsParams(
          page: 1,
          limit: 20,
          unreadOnly: false,
        ),
      );

      // Update unread count
      final unreadCount = await _getUnreadCountUseCase(NoParams());

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        hasMore: notifications.length == 20,
        currentPage: 1,
      ));
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    add(const LoadNotifications(refresh: true));
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final count = await _getUnreadCountUseCase(NoParams());
      emit(UnreadCountLoaded(count: count));
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }
}
