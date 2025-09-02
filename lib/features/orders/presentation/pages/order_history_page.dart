import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_details_dialog.dart';
import '../../data/models/order_model.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    context.read<OrdersBloc>().add(LoadUserOrders(
      page: _currentPage,
      limit: 5,
      status: _selectedStatus,
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  void _loadMoreOrders() {
    final state = context.read<OrdersBloc>().state;
    if (state is OrdersLoaded && state.pagination?.hasNext == true && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      
      context.read<OrdersBloc>().add(LoadMoreUserOrders(
        page: _currentPage,
        limit: 5,
        status: _selectedStatus,
      ));
      
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onStatusFilterChanged(String? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    _loadOrders();
  }

  void _onOrderTap(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Order History',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.surface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Status',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('All', null),
                      const SizedBox(width: 8),
                      _buildStatusChip('Submitted', 'submitted'),
                      const SizedBox(width: 8),
                      _buildStatusChip('Accepted', 'accepted'),
                      const SizedBox(width: 8),
                      _buildStatusChip('Being Packed', 'packing'),
                      const SizedBox(width: 8),
                      _buildStatusChip('Delivered', 'delivered'),
                      const SizedBox(width: 8),
                      _buildStatusChip('Store Rejected', 'rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Orders List
          Expanded(
            child: BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                if (state is OrdersLoading && _currentPage == 1) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is OrdersError && _currentPage == 1) {
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
                          'Failed to load orders',
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOrders,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OrdersLoaded) {
                  if (state.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders found',
                            style: AppTextStyles.h5.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You haven\'t placed any orders yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _currentPage = 1;
                      });
                      _loadOrders();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.orders.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.orders.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        final order = state.orders[index] as OrderModel;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrderCard(
                            order: order,
                            onTap: () => _onOrderTap(order),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    
    return FilterChip(
      label: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.surface : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        _onStatusFilterChanged(selected ? status : null);
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }
}
