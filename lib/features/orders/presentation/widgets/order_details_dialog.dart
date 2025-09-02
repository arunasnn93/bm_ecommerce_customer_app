import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/order_model.dart';
import 'image_preview_dialog.dart';

class OrderDetailsDialog extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsDialog({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details',
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.surface.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Section
                    _buildSection(
                      'Status',
                      Icons.info_outline,
                      [
                        _buildStatusRow(order.status),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                                         // Order Items Section
                     if (order.orderItems.isNotEmpty)
                       _buildSection(
                         'Order Items',
                         Icons.shopping_basket_outlined,
                         order.orderItems.map((item) => _buildItemRow(item as OrderItemModel)).toList(),
                       ),
                    
                    if (order.orderItems.isNotEmpty) const SizedBox(height: 20),
                    
                                         // Order Images Section
                     if (order.orderImages.isNotEmpty)
                       _buildSection(
                         'Order Images',
                         Icons.photo_library_outlined,
                         [
                           _buildImagesGrid(order.orderImages.cast<OrderImageModel>()),
                         ],
                       ),
                    
                    if (order.orderImages.isNotEmpty) const SizedBox(height: 20),
                    
                    // Delivery Information Section
                    _buildSection(
                      'Delivery Information',
                      Icons.location_on_outlined,
                      [
                        _buildInfoRow('Address', order.deliveryAddress),
                        _buildInfoRow('Phone', order.deliveryPhone),
                        if (order.notes != null && order.notes!.isNotEmpty)
                          _buildInfoRow('Notes', order.notes!),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Order Summary Section
                    _buildSection(
                      'Order Summary',
                      Icons.receipt_outlined,
                      [
                        _buildInfoRow('Total Amount', '₹${order.totalAmount}'),
                        _buildInfoRow('Order Date', _formatDateTime(order.createdAt)),
                        _buildInfoRow('Last Updated', _formatDateTime(order.updatedAt)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildStatusRow(String status) {
    Color statusColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'submitted':
        statusColor = AppColors.info;
        displayText = 'Submitted';
        break;
      case 'accepted':
        statusColor = AppColors.primary;
        displayText = 'Accepted';
        break;
      case 'packing':
        statusColor = AppColors.warning;
        displayText = 'Being Packed';
        break;
      case 'delivered':
        statusColor = AppColors.success;
        displayText = 'Delivered';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        displayText = 'Store Rejected';
        break;
      default:
        statusColor = AppColors.textSecondary;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            displayText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Qty: ${item.quantity}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesGrid(List<OrderImageModel> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return GestureDetector(
          onTap: () => _showImagePreview(context, image),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.network(
                    image.url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                  // Zoom indicator overlay
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showImagePreview(BuildContext context, OrderImageModel image) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ImagePreviewDialog(
        imageUrl: image.url,
        imageName: image.filename,
      ),
    );
  }
}
