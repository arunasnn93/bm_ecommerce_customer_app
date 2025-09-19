import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/logout_service.dart';
import '../../../../core/services/notification_realtime_manager.dart';
import '../bloc/auth_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../store/presentation/pages/virtual_tour_page.dart';
import '../../../orders/presentation/pages/place_order_page.dart';
import '../../../orders/presentation/pages/order_history_page.dart';
import '../../../orders/presentation/pages/track_order_page.dart';
import '../../../offers/presentation/pages/offers_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../../shared/widgets/logout_confirmation_dialog.dart';
import '../../../../shared/widgets/loading_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _welcomeMessage = 'Welcome back!';

  @override
  void initState() {
    super.initState();
    _loadWelcomeMessage();
    _loadNotifications();
    _startRealtimeNotifications();
  }
  
  @override
  void dispose() {
    // Stop real-time notifications when leaving the page
    NotificationRealtimeManager.instance.stopListening();
    super.dispose();
  }

  Future<void> _loadWelcomeMessage() async {
    try {
      final welcomeMessage = await UserService.getWelcomeMessage();
      if (mounted) {
        setState(() {
          _welcomeMessage = welcomeMessage;
        });
      }
    } catch (e) {
      print('❌ Error loading welcome message: $e');
      // Keep default message if error occurs
    }
  }

  void _loadNotifications() {
    // Load notifications and unread count
    try {
      context.read<NotificationsBloc>().add(const LoadNotifications(limit: 5));
    } catch (e) {
      print('❌ Error loading notifications: $e');
    }
  }
  
  void _startRealtimeNotifications() {
    // Start real-time notifications for the current user
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        final userId = authState.authResult.user.id;
        final notificationsBloc = context.read<NotificationsBloc>();
        
        // Add a small delay to ensure everything is initialized
        Future.delayed(const Duration(seconds: 1), () {
          NotificationRealtimeManager.instance.startListening(notificationsBloc, userId);
        });
      }
    } catch (e) {
      // Error starting real-time notifications
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
          'Beena Mart',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationsLoaded) {
                unreadCount = state.unreadCount;
              }
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: AppColors.surface),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.surface),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _welcomeMessage,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover amazing products and offers',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Main Sections Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildSectionCard(
                  context,
                  'Take a Virtual Tour',
                  Icons.view_in_ar,
                  AppColors.secondary,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VirtualTourPage(),
                    ),
                  ),
                ),
                _buildSectionCard(
                  context,
                  'Place an Order',
                  Icons.shopping_cart,
                  AppColors.primary,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PlaceOrderPage(),
                    ),
                  ),
                ),
                _buildSectionCard(
                  context,
                  'Order History',
                  Icons.history,
                  AppColors.info,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrderHistoryPage(),
                    ),
                  ),
                ),
                _buildSectionCard(
                  context,
                  'Offers Zone',
                  Icons.local_offer,
                  AppColors.warning,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OffersPage(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            _buildQuickActionCard(
              context,
              'Track Your Order',
              'Check the status of your recent orders',
              Icons.local_shipping,
              AppColors.success,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TrackOrderPage(),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            
            _buildQuickActionCard(
              context,
              'Customer Support',
              'Get help with your orders and queries',
              Icons.support_agent,
              AppColors.info,
            ),
            
            const SizedBox(height: 8),
            
            
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    ));
  }
  
  void _showLogoutDialog(BuildContext context) {
    LogoutConfirmationDialog.show(
      context,
      onConfirm: () => _performLogout(context),
    );
  }

  void _performLogout(BuildContext context) async {
    // Show loading dialog
    LoadingDialog.show(
      context,
      message: 'Logging out...',
    );

    try {
      // Clear all session data
      await LogoutService.clearAllSessionData();
      
      // Close loading dialog
      LoadingDialog.hide(context);
      
      // Navigate to login page with fallback
      try {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } catch (navError) {
        // Fallback: try to pop all routes and push login
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed('/login');
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      // Close loading dialog
      LoadingDialog.hide(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
