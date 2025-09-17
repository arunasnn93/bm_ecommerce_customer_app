import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/logout_service.dart';
import '../../../../core/services/web_push_service.dart';
import '../bloc/auth_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../store/presentation/pages/virtual_tour_page.dart';
import '../../../orders/presentation/pages/place_order_page.dart';
import '../../../orders/presentation/pages/order_history_page.dart';
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
            ),
            
            const SizedBox(height: 8),
            
            // FCM Token Generation Button (for testing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Push Notifications',
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate FCM token for push notifications',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                   // Request Permission Button
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () async {
                         final permission = await WebPushService.requestNotificationPermission();
                         
                         String message;
                         Color backgroundColor;
                         
                         switch (permission) {
                           case 'granted':
                             message = '✅ Permission granted! You can now generate web push subscriptions.';
                             backgroundColor = AppColors.success;
                             break;
                           case 'denied':
                             message = '❌ Permission denied. Please enable notifications in your browser settings.';
                             backgroundColor = AppColors.error;
                             break;
                           case 'not-supported':
                             message = '❌ Notifications not supported in this browser.';
                             backgroundColor = AppColors.error;
                             break;
                           case 'error':
                             message = '❌ Error requesting permission. Check console for details.';
                             backgroundColor = AppColors.error;
                             break;
                           default:
                             message = 'Permission result: $permission';
                             backgroundColor = AppColors.info;
                         }
                         
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(message),
                             backgroundColor: backgroundColor,
                             duration: const Duration(seconds: 5),
                           ),
                         );
                         
                         // Show instructions dialog if permission is denied
                         if (permission == 'denied') {
                           showDialog(
                             context: context,
                             builder: (context) => AlertDialog(
                               title: Text('Enable Notifications'),
                               content: Column(
                                 mainAxisSize: MainAxisSize.min,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('To enable push notifications:'),
                                   const SizedBox(height: 8),
                                   Text('1. Click the lock icon in your browser address bar'),
                                   Text('2. Set "Notifications" to "Allow"'),
                                   Text('3. Refresh the page'),
                                   Text('4. Try requesting permission again'),
                                   const SizedBox(height: 8),
                                   Text('Or check your browser settings:'),
                                   const SizedBox(height: 4),
                                   Text('• Chrome: Settings → Privacy → Site Settings → Notifications'),
                                   Text('• Firefox: Settings → Privacy → Permissions → Notifications'),
                                   Text('• Safari: Preferences → Websites → Notifications'),
                                 ],
                               ),
                               actions: [
                                 TextButton(
                                   onPressed: () => Navigator.of(context).pop(),
                                   child: Text('OK'),
                                 ),
                               ],
                             ),
                           );
                         }
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.warning,
                         foregroundColor: AppColors.surface,
                       ),
                       child: Text(
                         'Request Notification Permission',
                         style: AppTextStyles.bodyMedium.copyWith(
                           color: AppColors.surface,
                         ),
                       ),
                     ),
                   ),
                  
                  const SizedBox(height: 8),
                  
                   // Setup Push Listener Button
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () async {
                         await WebPushService.setupPushNotificationListener();
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('Web push notification listener setup completed. Check console for details.'),
                             backgroundColor: AppColors.info,
                           ),
                         );
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.secondary,
                         foregroundColor: AppColors.surface,
                       ),
                       child: Text(
                         'Setup Web Push Listener',
                         style: AppTextStyles.bodyMedium.copyWith(
                           color: AppColors.surface,
                         ),
                       ),
                     ),
                   ),
                  
                  const SizedBox(height: 8),
                  
                   // Show Full Web Push Subscription Button
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () async {
                         final subscription = WebPushService.getCurrentSubscription();
                         if (subscription != null) {
                           showDialog(
                             context: context,
                             builder: (context) => AlertDialog(
                               title: Text('Web Push Subscription'),
                               content: Column(
                                 mainAxisSize: MainAxisSize.min,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('Web Push Subscription:'),
                                   const SizedBox(height: 8),
                                   Container(
                                     padding: const EdgeInsets.all(8),
                                     decoration: BoxDecoration(
                                       color: AppColors.surface,
                                       borderRadius: BorderRadius.circular(8),
                                       border: Border.all(color: AppColors.border),
                                     ),
                                     child: SelectableText(
                                       subscription,
                                       style: AppTextStyles.bodySmall.copyWith(
                                         fontFamily: 'monospace',
                                       ),
                                     ),
                                   ),
                                   const SizedBox(height: 8),
                                   Text(
                                     'This subscription is automatically sent to your backend.',
                                     style: AppTextStyles.bodySmall.copyWith(
                                       color: AppColors.textSecondary,
                                     ),
                                   ),
                                 ],
                               ),
                               actions: [
                                 TextButton(
                                   onPressed: () => Navigator.of(context).pop(),
                                   child: Text('Close'),
                                 ),
                               ],
                             ),
                           );
                         } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content: Text('No web push subscription available. Generate one first.'),
                               backgroundColor: AppColors.error,
                             ),
                           );
                         }
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.success,
                         foregroundColor: AppColors.surface,
                       ),
                       child: Text(
                         'Show Web Push Subscription',
                         style: AppTextStyles.bodyMedium.copyWith(
                           color: AppColors.surface,
                         ),
                       ),
                     ),
                   ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                       Expanded(
                         child: ElevatedButton(
                           onPressed: () async {
                             // Generate web push subscription
                             final subscription = await WebPushService.generateWebPushSubscription();
                             if (subscription != null) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text('Web Push Subscription generated successfully!'),
                                   backgroundColor: AppColors.success,
                                 ),
                               );
                             } else {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text('Failed to generate web push subscription. Check console for details.'),
                                   backgroundColor: AppColors.error,
                                 ),
                               );
                             }
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppColors.primary,
                             foregroundColor: AppColors.surface,
                           ),
                           child: Text(
                             'Generate Web Push Subscription',
                             style: AppTextStyles.bodyMedium.copyWith(
                               color: AppColors.surface,
                             ),
                           ),
                         ),
                       ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Send test notification
                            final success = await WebPushService.sendTestNotification();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Test notification sent successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to send test notification. Check console for details.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: AppColors.surface,
                          ),
                          child: Text(
                            'Send Test Notification',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildQuickActionCard(
              context,
              'Customer Support',
              'Get help with your orders and queries',
              Icons.support_agent,
              AppColors.info,
            ),
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
    Color color,
  ) {
    return Container(
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
    );
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
