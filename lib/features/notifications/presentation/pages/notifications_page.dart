import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NotificationsBloc>().add(const LoadNotifications());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<NotificationsBloc>().state;
      if (state is NotificationsLoaded && state.hasMore) {
        context.read<NotificationsBloc>().add(
          LoadNotifications(
            page: _currentPage + 1,
            limit: _pageSize,
          ),
        );
        _currentPage++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Notifications',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    context.read<NotificationsBloc>().add(
                      const MarkAllNotificationsAsRead(),
                    );
                  },
                  child: Text(
                    'Mark All Read',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is NotificationMarkedAsRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Notification marked as read'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is AllNotificationsMarkedAsRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('All notifications marked as read'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          } else if (state is NotificationsError) {
            return _buildErrorState(state.message);
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }
            return _buildNotificationsList(state);
          }
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationsBloc>().add(const LoadNotifications());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see your notifications here when they arrive',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationsBloc>().add(const RefreshNotifications());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          }

          final notification = state.notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () {
              // Handle notification tap
              _handleNotificationTap(notification);
            },
            onMarkAsRead: notification.isRead
                ? null
                : () {
                    context.read<NotificationsBloc>().add(
                      MarkNotificationAsRead(
                        notificationId: notification.id,
                      ),
                    );
                  },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(notification) {
    // Navigate to appropriate page based on notification type
    switch (notification.type) {
      case 'order_status_change':
        // Navigate to order details
        break;
      case 'admin_message':
        // Stay on notifications page
        break;
      case 'price_update':
        // Navigate to order details
        break;
      default:
        // Stay on notifications page
        break;
    }
  }
}
