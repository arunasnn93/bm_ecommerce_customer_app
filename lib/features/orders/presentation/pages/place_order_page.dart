import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_state.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/models/file_data.dart';
import '../../../../core/services/universal_upload_service.dart';
import '../../../../core/presentation/widgets/custom_button.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../widgets/universal_image_picker.dart';

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({Key? key}) : super(key: key);

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final _notesController = TextEditingController();
  final _bulkItemsController = TextEditingController();
  FileData? _selectedImage;
  String? _deliveryAddress;
  String? _deliveryPhone;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserService.getCurrentUser();
    final address = await UserService.getUserAddress();
    
    if (user != null) {
      setState(() {
        _deliveryAddress = address ?? 'Address not available';
        _deliveryPhone = user.mobileNumber;
      });
    }
  }

  // Removed _parseBulkItems function - no longer parsing items

  void _onImageSelected(FileData? imageData) {
    setState(() {
      _selectedImage = imageData;
    });
  }

  bool _canPlaceOrder() {
    return _bulkItemsController.text.trim().isNotEmpty || _selectedImage != null;
  }

  Future<void> _placeOrder() async {
    if (!_canPlaceOrder()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item or upload an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    _showLoadingDialog();

    try {
      // Additional fields
      final additionalFields = <String, String>{
        'bulk_items_text': _bulkItemsController.text.trim(),
        'delivery_address': _deliveryAddress ?? '',
        'delivery_phone': _deliveryPhone ?? '',
        'total_amount': '0', // Default to 0 for bulk orders
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
      };

      // Upload order using universal service
      final result = await UniversalUploadService.uploadOrder(
        items: [], // No longer using individual items
        imageData: _selectedImage,
        additionalFields: additionalFields,
      );

      // Hide loading dialog
      if (mounted) Navigator.of(context).pop();

      if (result['success'] == true) {
        // Extract order ID from response
        final orderId = _extractOrderId(result);
        
        // Debug logging to understand the response structure
        print('🔍 API Response: $result');
        print('📋 Extracted Order ID: $orderId');
        
        // Show success message with order ID
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                orderId != null 
                  ? 'Order created successfully! Order ID: $orderId'
                  : 'Order created successfully!'
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4), // Show longer for order ID
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      // Hide loading dialog if still showing
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Show loading dialog while order is being created
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while loading
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Creating your order...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Extract order ID from the API response
  String? _extractOrderId(Map<String, dynamic> result) {
    try {
      String? orderId;
      
      print('🔍 Attempting to extract order ID from result: $result');
      
      // Try different possible response structures
      final data = result['data'];
      
      if (data is Map<String, dynamic>) {
        print('📋 Data is Map: $data');
        // Check common field names for order ID
        orderId = data['id']?.toString() ?? 
                  data['order_id']?.toString() ?? 
                  data['orderId']?.toString() ??
                  data['_id']?.toString();
      } else if (data is String) {
        print('📋 Data is String: $data');
        
        // Try to parse the string as JSON (in case it's a JSON string)
        try {
          final parsedData = jsonDecode(data);
          if (parsedData is Map<String, dynamic>) {
            print('📋 Parsed string data as JSON: $parsedData');
            orderId = parsedData['id']?.toString() ?? 
                      parsedData['order_id']?.toString() ?? 
                      parsedData['orderId']?.toString() ??
                      parsedData['_id']?.toString();
          }
        } catch (e) {
          // If not JSON, check if it's a direct order ID
          if (_isValidOrderId(data)) {
            orderId = data;
          }
        }
      }
      
      // Fallback: check if order ID is directly in result
      orderId ??= result['id']?.toString() ?? 
                  result['order_id']?.toString() ?? 
                  result['orderId']?.toString() ??
                  result['_id']?.toString();
      
      print('🎯 Found potential order ID: $orderId');
      
      // Validate that we got a proper order ID (not entire response)
      if (orderId != null && _isValidOrderId(orderId)) {
        print('✅ Valid order ID extracted: $orderId');
        return orderId;
      }
      
      print('❌ No valid order ID found');
      return null;
    } catch (e) {
      print('❌ Error extracting order ID: $e');
      return null;
    }
  }

  /// Validate if the extracted string is a proper order ID
  bool _isValidOrderId(String value) {
    // Remove whitespace
    value = value.trim();
    
    // Check if it's too long (likely entire response)
    if (value.length > 100) {
      return false;
    }
    
    // Check if it contains JSON-like characters (likely entire response)
    if (value.contains('{') || value.contains('[') || value.contains('}') || value.contains(']')) {
      return false;
    }
    
    // Check if it contains success/error messages
    if (value.toLowerCase().contains('success') || 
        value.toLowerCase().contains('error') ||
        value.toLowerCase().contains('message')) {
      return false;
    }
    
    // Must not be empty
    if (value.isEmpty) {
      return false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order created successfully! ID: ${state.order.id}'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            return Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Upload Section - Moved to Top
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '📷 Upload Image (Optional)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                UniversalImagePicker(
                                  selectedImage: _selectedImage,
                                  onImageSelected: _onImageSelected,
                                  label: 'Upload Image of Shopping List',
                                  hint: 'Tap to select an image file (JPG, PNG, GIF, WebP)',
                                  maxFileSizeInMB: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bulk Order Items Section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '🛒 Order Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Type your shopping list below (one item per line)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: _bulkItemsController,
                                    maxLines: 8,
                                    minLines: 4,
                                    decoration: const InputDecoration(
                                      hintText: 'Rice 2kg\nTomatoes 1kg\nOnions 500g\nMilk 1L\nBread 1 packet\n\n💡 Tips:\n• One item per line\n• Include quantity (e.g., "2kg", "1L", "500g")\n• Examples: "Rice 2kg", "Tomatoes - 1kg", "Onions: 500g"',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(12),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                    onChanged: (value) {
                                      setState(() {}); // Trigger rebuild for validation
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Info about bulk orders
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber.shade200),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '💡 How it works:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '• Type your shopping list as shown in the examples\n• Our delivery executive will read your list and calculate the total\n• You can clarify any items when they call to confirm',
                                        style: TextStyle(fontSize: 14, color: Colors.amber),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes Section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '📝 Additional Notes (Optional)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  label: 'Notes',
                                  controller: _notesController,
                                  hint: 'Any special instructions or notes...',
                                  isMultiline: true,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Extra space for fixed button
                      ],
                    ),
                  ),
                ),
                
                // Fixed bottom section with Place Order button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Validation Message
                      if (!_canPlaceOrder())
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            '⚠️ Please add items to your order or upload an image',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // Place Order Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Place Order',
                          onPressed: _placeOrder,
                          isLoading: false,
                          isEnabled: _canPlaceOrder(),
                          backgroundColor: _canPlaceOrder() 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _bulkItemsController.dispose();
    super.dispose();
  }
}
