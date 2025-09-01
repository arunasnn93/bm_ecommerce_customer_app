import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/api_requests.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../../../../core/services/jwt_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/presentation/widgets/custom_button.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/image_picker_widget.dart';

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({Key? key}) : super(key: key);

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final _notesController = TextEditingController();
  final List<OrderItemRequest> _orderItems = [];
  File? _selectedImage;
  String? _deliveryAddress;
  String? _deliveryPhone;
  bool _isLoading = false;

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

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onItemAdded: (name, quantity) {
          setState(() {
            _orderItems.add(OrderItemRequest(name: name, quantity: quantity));
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  void _updateItemQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        _orderItems[index] = OrderItemRequest(
          name: _orderItems[index].name,
          quantity: newQuantity,
        );
      });
    } else {
      _removeItem(index);
    }
  }

  void _pickImage(File imageFile) {
    setState(() {
      _selectedImage = imageFile;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  bool _canPlaceOrder() {
    return _orderItems.isNotEmpty || _selectedImage != null;
  }

  void _placeOrder() {
    if (!_canPlaceOrder()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item or upload an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = CreateOrderRequest(
      orderItems: _orderItems,
      deliveryAddress: _deliveryAddress ?? '',
      deliveryPhone: _deliveryPhone ?? '',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      image: _selectedImage,
    );

    context.read<OrdersBloc>().add(CreateOrderEvent(request: request));
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
            _isLoading = state is OrdersLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Order Items Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '🛒 Order Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _addItem,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Item'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_orderItems.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text(
                                    'No items added yet',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _orderItems.length,
                                itemBuilder: (context, index) {
                                  final item = _orderItems[index];
                                  return CartItemWidget(
                                    name: item.name,
                                    quantity: item.quantity,
                                    onQuantityChanged: (newQuantity) {
                                      _updateItemQuantity(index, newQuantity);
                                    },
                                    onRemove: () => _removeItem(index),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image Upload Section
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
                            ImagePickerWidget(
                              selectedImage: _selectedImage,
                              onImagePicked: _pickImage,
                              onImageRemoved: _removeImage,
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
                    const SizedBox(height: 32),

                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Place Order',
                        onPressed: _placeOrder,
                        isLoading: _isLoading,
                        isEnabled: _canPlaceOrder(),
                        backgroundColor: _canPlaceOrder() 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Validation Message
                    if (!_canPlaceOrder())
                      const Center(
                        child: Text(
                          '⚠️ Please add at least one item or upload an image',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                          ),
                        ),
                      ),
                                     ],
                 ),
               );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
