import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/user_service.dart';
import '../bloc/auth_bloc.dart';
import '../../../store/presentation/pages/virtual_tour_page.dart';
import '../../../orders/presentation/pages/place_order_page.dart';

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
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.surface),
            onPressed: () {
              // TODO: Navigate to notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon!'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.surface),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
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
                  'Previous Orders',
                  Icons.history,
                  AppColors.info,
                  () => _showComingSoon(context, 'Previous Orders'),
                ),
                _buildSectionCard(
                  context,
                  'Special Offers',
                  Icons.local_offer,
                  AppColors.warning,
                  () => _showComingSoon(context, 'Special Offers'),
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
